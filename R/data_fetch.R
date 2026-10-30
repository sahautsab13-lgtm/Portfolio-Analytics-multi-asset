# Yahoo Finance is a third-party source. Data are cached only for this R session.
.price_cache <- new.env(parent = emptyenv())

cache_key <- function(ticker, start_date, end_date) {
  paste(toupper(trimws(ticker)), as.character(start_date), as.character(end_date), sep = "|")
}

fetch_adjusted_prices <- function(ticker, start_date, end_date, cache = .price_cache) {
  if (!requireNamespace("quantmod", quietly = TRUE)) {
    return(list(ok = FALSE, message = "Package 'quantmod' is required for Yahoo Finance downloads.", data = NULL))
  }
  ticker <- toupper(trimws(ticker))
  if (!grepl("^[A-Z0-9.^-]+$", ticker)) {
    return(list(ok = FALSE, message = sprintf("'%s' is not a valid ticker format.", ticker), data = NULL))
  }
  key <- cache_key(ticker, start_date, end_date)
  if (exists(key, envir = cache, inherits = FALSE)) return(get(key, envir = cache))
  result <- tryCatch({
    x <- quantmod::getSymbols(ticker, src = "yahoo", from = start_date, to = end_date,
      auto.assign = FALSE, warnings = FALSE)
    adj_col <- grep("Adjusted$", colnames(x), value = TRUE)
    close_col <- grep("Close$", colnames(x), value = TRUE)
    price <- if (length(adj_col)) x[, adj_col[1]] else if (length(close_col)) x[, close_col[1]] else NULL
    if (is.null(price) || NROW(price) < 2L) stop("No usable adjusted/closing price observations returned.")
    price <- price[is.finite(as.numeric(price)) & as.numeric(price) > 0]
    if (NROW(price) < 2L) stop("Downloaded data has fewer than two valid positive prices.")
    colnames(price) <- ticker
    list(ok = TRUE, message = "", data = price)
  }, error = function(e) list(ok = FALSE, message = sprintf("%s: %s", ticker, conditionMessage(e)), data = NULL))
  assign(key, result, envir = cache)
  result
}

fetch_portfolio_prices <- function(tickers, start_date, end_date) {
  results <- lapply(tickers, fetch_adjusted_prices, start_date = start_date, end_date = end_date)
  names(results) <- tickers
  successes <- results[vapply(results, function(x) x$ok, logical(1))]
  failures <- results[!vapply(results, function(x) x$ok, logical(1))]
  list(successes = successes, failures = failures)
}
