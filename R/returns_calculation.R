daily_simple_returns <- function(prices) {
  x <- as.matrix(prices)
  if (NROW(x) < 2L || any(x <= 0, na.rm = TRUE)) stop("Prices require at least two positive observations.")
  out <- x[-1, , drop = FALSE] / x[-NROW(x), , drop = FALSE] - 1
  if (inherits(prices, "xts")) {
    out <- xts::xts(out, order.by = zoo::index(prices)[-1])
    colnames(out) <- colnames(prices)
  }
  out
}

annualized_arithmetic_return <- function(returns, trading_days = 252) mean(returns, na.rm = TRUE) * trading_days
annualized_volatility <- function(returns, trading_days = 252) stats::sd(returns, na.rm = TRUE) * sqrt(trading_days)
cumulative_growth <- function(returns) cumprod(1 + as.numeric(returns))
