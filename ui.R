library(shiny)
library(bslib)
library(plotly)
library(DT)

ui <- page_navbar(
  title = "Portfolio Analytics", id = "nav",
  theme = bs_theme(version = 5, bootswatch = "flatly", primary = "#0b5d5e"),
  header = tags$div(class = "p-2 text-muted", "Educational analytics only • INR portfolios • Historical daily Yahoo Finance data"),
  nav_panel("Dashboard",
    layout_column_wrap(width = 1/4,
      value_box("Investment", textOutput("investment_value"), showcase = bsicons::bs_icon("cash-stack")),
      value_box("Annualized return", textOutput("portfolio_return"), showcase = bsicons::bs_icon("graph-up-arrow")),
      value_box("Annualized volatility", textOutput("portfolio_volatility"), showcase = bsicons::bs_icon("activity")),
      value_box("Sharpe ratio", textOutput("portfolio_sharpe"), showcase = bsicons::bs_icon("speedometer"))
    ),
    layout_columns(card(card_header("Historical growth"), plotlyOutput("growth_plot", height = 330)),
      card(card_header("Allocation by asset class"), plotlyOutput("class_allocation_plot", height = 330)), col_widths = c(7, 5)),
    card(card_header("Important methodology"),
      "Portfolio returns assume daily rebalancing to target weights. Historical data do not predict future returns; costs, taxes, liquidity and slippage are excluded.")
  ),
  nav_panel("Portfolio Builder",
    layout_sidebar(
      sidebar(width = 360, open = "desktop",
        numericInput("investment", "Total investment (INR)", value = 1000000, min = 1, step = 10000),
        dateRangeInput("dates", "Historical date range", start = Sys.Date() - 365 * 3, end = Sys.Date() - 1,
          min = as.Date("2000-01-01")),
        numericInput("risk_free", "Annual risk-free rate (%)", value = 6, min = 0, max = 100, step = 0.25),
        hr(), selectInput("registry_choice", "Add an example instrument", choices = NULL),
        actionButton("add_registry", "Add selected example", class = "btn-primary"),
        textInput("custom_ticker", "Custom Yahoo Finance ticker", placeholder = "e.g., HDFCBANK.NS"),
        selectInput("custom_class", "Custom instrument asset class", choices = c("Equity", "Debt", "Gold")),
        actionButton("add_custom", "Add custom instrument"), hr(),
        actionButton("remove_selected", "Remove selected instruments", class = "btn-outline-danger"),
        helpText("Examples are not guarantees of Yahoo availability. Validate data coverage before interpreting results.")
      ),
      h4("Selected instruments"), uiOutput("instrument_controls"), hr(), h4("Strategic asset allocation"), uiOutput("class_controls"),
      div(class = "mt-3", uiOutput("allocation_message")), br(), DTOutput("allocation_table")
    )
  ),
  nav_panel("Assets & Instruments",
    layout_columns(card(card_header("Normalized historical performance"), plotlyOutput("normalized_plot", height = 380)),
      card(card_header("Instrument metrics"), DTOutput("instrument_metrics")), col_widths = c(7, 5)),
    card(card_header("Market-data coverage"), DTOutput("coverage_table"))
  ),
  nav_panel("Risk Analysis",
    layout_columns(card(card_header("Correlation heatmap"), plotlyOutput("correlation_plot", height = 450)),
      card(card_header("Risk summary"), DTOutput("risk_table")), col_widths = c(7, 5)),
    card(card_header("Diversification"), textOutput("diversification_text"))
  ),
  nav_panel("Comparison",
    card(card_header("Diversified vs equity-only"), plotlyOutput("comparison_plot", height = 400)),
    card(card_header("Comparison metrics"), DTOutput("comparison_table")),
    p("The equity-only comparison is a hypothetical, daily-rebalanced portfolio of the selected equity instruments. It is not an index benchmark and may be unavailable when no equity instrument is selected.")
  ),
  nav_panel("About & limitations",
    h3("Data and methodology"),
    p("Prices are requested from Yahoo Finance, a third-party source rather than an official NSE data feed. Adjusted closes are used when Yahoo supplies them; otherwise closing prices are used."),
    tags$ul(tags$li("Common valid dates are used; missing values are never fabricated."), tags$li("Annualized arithmetic return and realized CAGR are reported separately."),
      tags$li("This is an educational tool, not personalized investment advice or a recommendation."))
  )
)
