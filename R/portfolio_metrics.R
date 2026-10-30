instrument_metrics <- function(returns) {
  x <- as.matrix(returns)
  data.frame(ticker = colnames(x), mean_daily_return = colMeans(x, na.rm = TRUE), daily_variance = apply(x, 2, stats::var, na.rm = TRUE),
    daily_volatility = apply(x, 2, stats::sd, na.rm = TRUE), annualized_return = apply(x, 2, annualized_arithmetic_return),
    annualized_volatility = apply(x, 2, annualized_volatility), cumulative_return = apply(x, 2, function(z) prod(1 + z, na.rm = TRUE) - 1), row.names = NULL)
}

portfolio_daily_returns <- function(returns, weights_pct) {
  x <- as.matrix(returns); w <- weights_pct[colnames(x)] / 100
  if (anyNA(w) || abs(sum(w) - 1) > 1e-8) stop("Portfolio weights must match return columns and sum to 100%.")
  as.numeric(x %*% w)
}

max_drawdown <- function(returns) {
  wealth <- cumprod(1 + as.numeric(returns)); min(wealth / cummax(wealth) - 1)
}

portfolio_metrics <- function(returns, weights_pct, annual_risk_free_rate = 0.06, trading_days = 252) {
  p <- portfolio_daily_returns(returns, weights_pct)
  cov_daily <- stats::cov(as.matrix(returns), use = "complete.obs")
  w <- weights_pct[colnames(as.matrix(returns))] / 100
  variance_annual <- as.numeric(t(w) %*% (cov_daily * trading_days) %*% w)
  annual_return <- annualized_arithmetic_return(p, trading_days)
  annual_vol <- sqrt(variance_annual)
  n <- length(p)
  list(daily_returns = p, annualized_return = annual_return, annualized_volatility = annual_vol,
    annualized_variance = variance_annual, cumulative_growth = cumprod(1 + p),
    cagr = tail(cumprod(1 + p), 1)^(trading_days / n) - 1,
    maximum_drawdown = max_drawdown(p), sharpe_ratio = if (annual_vol == 0) NA_real_ else (annual_return - annual_risk_free_rate) / annual_vol,
    covariance = cov_daily, correlation = stats::cor(as.matrix(returns), use = "complete.obs"))
}

equity_only_weights <- function(instruments, effective_weight_pct) {
  ids <- instruments$ticker[instruments$asset_class == "Equity"]
  if (!length(ids)) return(NULL)
  w <- effective_weight_pct[ids]; w / sum(w) * 100
}
