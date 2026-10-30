safe_id <- function(x) gsub("[^A-Za-z0-9]", "_", x)

server <- function(input, output, session) {
  # A verified three-asset starter portfolio gives the dashboard useful content on first load.
  starter_tickers <- c("RELIANCE.NS", "LIQUIDBEES.NS", "GOLDBEES.NS")
  instruments <- reactiveVal(instrument_registry[instrument_registry$ticker %in% starter_tickers,
    c("ticker", "asset_class"), drop = FALSE])
  input_number <- function(id, fallback = NA_real_) {
    value <- suppressWarnings(as.numeric(input[[id]]))
    if (length(value) != 1L || is.na(value)) fallback else value
  }
  observe(updateSelectInput(session, "registry_choice", choices = stats::setNames(instrument_registry$ticker,
    paste(instrument_registry$name, "(", instrument_registry$ticker, ")"))))

  add_instrument <- function(ticker, asset_class) {
    ticker <- toupper(trimws(ticker)); current <- instruments()
    if (!nzchar(ticker)) { showNotification("Enter a ticker symbol.", type = "error"); return() }
    if (ticker %in% current$ticker) { showNotification("That ticker is already selected.", type = "warning"); return() }
    instruments(rbind(current, data.frame(ticker = ticker, asset_class = asset_class, stringsAsFactors = FALSE)))
  }
  observeEvent(input$add_registry, {
    row <- instrument_registry[instrument_registry$ticker == input$registry_choice, , drop = FALSE]
    if (NROW(row)) add_instrument(row$ticker, row$asset_class)
  })
  observeEvent(input$add_custom, add_instrument(input$custom_ticker, input$custom_class))
  observeEvent(input$remove_selected, {
    current <- instruments(); if (!NROW(current)) return()
    keep <- vapply(current$ticker, function(t) isTRUE(input[[paste0("keep_", safe_id(t))]]), logical(1))
    instruments(current[keep, , drop = FALSE])
  })

  output$instrument_controls <- renderUI({
    current <- instruments(); if (!NROW(current)) return(tags$p(class = "text-muted", "Add one or more instruments to begin."))
    tagList(lapply(seq_len(NROW(current)), function(i) {
      t <- current$ticker[i]; id <- safe_id(t)
      card(class = "mb-2", layout_columns(
        checkboxInput(paste0("keep_", id), NULL, value = TRUE),
        tags$strong(t), tags$span(class = "text-muted", current$asset_class[i]),
        numericInput(paste0("inst_", id), "Within-class allocation (%)",
          value = input_number(paste0("inst_", id), 100 / sum(current$asset_class == current$asset_class[i])), min = 0, max = 100, step = 1),
        col_widths = c(1, 3, 2, 6)
      ))
    }))
  })
  output$class_controls <- renderUI({
    current <- instruments(); active <- unique(current$asset_class)
    if (!length(active)) return(tags$p(class = "text-muted", "Asset classes appear after instruments are added."))
    tagList(lapply(active, function(cls) numericInput(paste0("class_", cls), paste(cls, "allocation (%)"),
      value = input_number(paste0("class_", cls), 100 / length(active)), min = 0, max = 100, step = 1)))
  })

  allocations <- reactive({
    current <- instruments()
    classes <- unique(current$asset_class)
    class_w <- vapply(classes, function(x) input_number(paste0("class_", x)), numeric(1)); names(class_w) <- classes
    inst_w <- vapply(current$ticker, function(x) input_number(paste0("inst_", safe_id(x))), numeric(1)); names(inst_w) <- current$ticker
    list(instruments = current, class_weights = class_w, instrument_weights = inst_w)
  })
  allocation_error <- reactive({
    a <- allocations()
    instrument_error <- validate_instruments(a$instruments)
    if (!is.null(instrument_error)) return(instrument_error)
    validate_allocations(a$instruments, a$class_weights, a$instrument_weights)
  })
  output$allocation_message <- renderUI({ if (is.null(allocation_error())) tags$div(class = "alert alert-success", "Allocation is valid: effective weights sum to 100%.") else tags$div(class = "alert alert-warning", allocation_error()) })
  output$allocation_table <- renderDT({
    a <- allocations(); req(is.null(allocation_error()))
    datatable(allocation_table(a$instruments, a$class_weights, a$instrument_weights, input$investment), rownames = FALSE,
      options = list(dom = "t", pageLength = 10), colnames = c("Ticker", "Asset class", "Class %", "Within class %", "Effective %", "Amount (INR)"))
  })

  analysis <- reactive({
    validate(need(!is.null(input$load_data) && input$load_data > 0, "Open Portfolio Builder and click 'Load / refresh market data'."))
    a <- allocations(); validate(need(is.null(allocation_error()), allocation_error()))
    validate(need(input$dates[1] < input$dates[2], "Select a valid historical date range."))
    fetched <- fetch_portfolio_prices(a$instruments$ticker, input$dates[1], input$dates[2])
    validate(need(!length(fetched$failures), paste(vapply(fetched$failures, `[[`, character(1), "message"), collapse = " | ")))
    prices <- align_price_series(fetched$successes)
    validate(need(!is.null(prices), "No common valid price dates exist for the selected instruments."))
    returns <- daily_simple_returns(prices)
    validate(need(is.null(validate_common_returns(returns)), validate_common_returns(returns)))
    weights <- effective_weights(a$instruments, a$class_weights, a$instrument_weights)
    metrics <- portfolio_metrics(returns, weights, input$risk_free / 100)
    list(a = a, fetched = fetched, prices = prices, returns = returns, weights = weights, metrics = metrics)
  })
  with_analysis <- function(expr) { tryCatch(expr, error = function(e) NULL) }
  output$investment_value <- renderText(currency_inr(input$investment))
  output$portfolio_return <- renderText({ x <- with_analysis(analysis()); if (is.null(x)) "—" else scales::percent(x$metrics$annualized_return, accuracy = 0.1) })
  output$portfolio_volatility <- renderText({ x <- with_analysis(analysis()); if (is.null(x)) "—" else scales::percent(x$metrics$annualized_volatility, accuracy = 0.1) })
  output$portfolio_sharpe <- renderText({ x <- with_analysis(analysis()); if (is.null(x)) "—" else format(round(x$metrics$sharpe_ratio, 2), nsmall = 2) })
  output$growth_plot <- renderPlotly({ x <- analysis(); growth_plot(zoo::index(x$returns), x$metrics$cumulative_growth) })
  output$class_allocation_plot <- renderPlotly({ x <- analysis(); cw <- x$a$class_weights; plot_ly(labels = names(cw), values = as.numeric(cw), type = "pie", hole = .55) })
  output$normalized_plot <- renderPlotly({
    x <- analysis(); p <- x$prices / as.numeric(x$prices[1, ]) * 100
    chart <- plot_ly(x = zoo::index(p), y = p[, 1], type = "scatter", mode = "lines", name = colnames(p)[1])
    if (NCOL(p) > 1) for (i in 2:NCOL(p)) chart <- add_lines(chart, x = zoo::index(p), y = p[, i], name = colnames(p)[i])
    layout(chart, yaxis = list(title = "Indexed to 100"))
  })
  output$instrument_metrics <- renderDT({ x <- analysis(); datatable(round(instrument_metrics(x$returns), 4), rownames = FALSE, options = list(dom = "t")) })
  output$coverage_table <- renderDT({ x <- analysis(); datatable(coverage_summary(x$fetched$successes, x$prices), rownames = FALSE, options = list(dom = "t")) })
  output$correlation_plot <- renderPlotly({ x <- analysis(); correlation_heatmap(x$metrics$correlation) })
  output$risk_table <- renderDT({ x <- analysis(); d <- data.frame(metric = c("Annualized arithmetic return", "Annualized volatility", "Annualized variance", "CAGR", "Maximum drawdown", "Sharpe ratio"), value = c(scales::percent(x$metrics$annualized_return), scales::percent(x$metrics$annualized_volatility), round(x$metrics$annualized_variance, 4), scales::percent(x$metrics$cagr), scales::percent(x$metrics$maximum_drawdown), round(x$metrics$sharpe_ratio, 2))); datatable(d, rownames = FALSE, options = list(dom = "t")) })
  output$diversification_text <- renderText({ x <- analysis(); c <- x$metrics$correlation; avg <- mean(c[upper.tri(c)]); if (is.nan(avg)) "One instrument is selected; correlation-based diversification cannot be assessed." else paste("Average pairwise correlation is", round(avg, 2), ". Lower (especially below 1) correlation can reduce portfolio volatility, but does not eliminate risk.") })
  comparison <- reactive({ x <- analysis(); w <- equity_only_weights(x$a$instruments, x$weights); if (is.null(w)) return(NULL); r <- x$returns[, names(w), drop = FALSE]; list(weights = w, metrics = portfolio_metrics(r, w, input$risk_free / 100)) })
  output$comparison_plot <- renderPlotly({ x <- analysis(); y <- comparison(); validate(need(!is.null(y), "Add at least one equity instrument to create an equity-only comparison.")); growth_plot(zoo::index(x$returns), x$metrics$cumulative_growth, y$metrics$cumulative_growth) })
  output$comparison_table <- renderDT({ x <- analysis(); y <- comparison(); validate(need(!is.null(y), "Add equity instruments to compare portfolios.")); d <- data.frame(metric = c("Annualized return", "Annualized volatility", "CAGR", "Maximum drawdown"), Diversified = c(x$metrics$annualized_return, x$metrics$annualized_volatility, x$metrics$cagr, x$metrics$maximum_drawdown), `Equity-only` = c(y$metrics$annualized_return, y$metrics$annualized_volatility, y$metrics$cagr, y$metrics$maximum_drawdown)); d[-1] <- lapply(d[-1], scales::percent, accuracy = .1); datatable(d, rownames = FALSE, options = list(dom = "t")) })
}
