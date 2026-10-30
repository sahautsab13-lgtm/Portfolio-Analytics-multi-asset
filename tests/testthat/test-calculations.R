test_that("daily simple returns and annualization use specified formulas", {
  prices <- cbind(A = c(100, 110, 121), B = c(100, 100, 110))
  r <- daily_simple_returns(prices)
  expect_equal(unname(r[, "A"]), c(.1, .1))
  expect_equal(annualized_arithmetic_return(c(.01, .02)), .015 * 252)
  expect_equal(annualized_volatility(c(.01, .02)), stats::sd(c(.01, .02)) * sqrt(252))
})

test_that("portfolio returns and covariance risk are weight-aware", {
  r <- cbind(A = c(.01, .02, -.01), B = c(0, .01, .02))
  w <- c(A = 60, B = 40)
  expect_equal(portfolio_daily_returns(r, w), c(.006, .016, .002))
  m <- portfolio_metrics(r, w, .05)
  expect_equal(m$annualized_variance, as.numeric(t(c(.6, .4)) %*% (stats::cov(r) * 252) %*% c(.6, .4)))
  expect_equal(m$annualized_volatility, sqrt(m$annualized_variance))
})

test_that("effective allocations sum to 100 percent", {
  instruments <- data.frame(ticker = c("A", "B", "C"), asset_class = c("Equity", "Equity", "Gold"))
  cw <- c(Equity = 70, Gold = 30); iw <- c(A = 50, B = 50, C = 100)
  expect_null(validate_allocations(instruments, cw, iw))
  expect_equal(sum(effective_weights(instruments, cw, iw)), 100)
  expect_equal(unname(effective_weights(instruments, cw, iw)), c(35, 35, 30))
})

test_that("invalid allocations and short common data are rejected", {
  instruments <- data.frame(ticker = "A", asset_class = "Equity")
  expect_match(validate_allocations(instruments, c(Equity = 90), c(A = 100)), "sum to 100")
  expect_match(validate_common_returns(matrix(0, nrow = 4, ncol = 1), min_observations = 5), "Only 4")
})

test_that("correlation matrix is correctly calculated", {
  r <- cbind(A = 1:5 / 100, B = 2 * (1:5) / 100)
  expect_equal(portfolio_metrics(r, c(A = 50, B = 50))$correlation[1, 2], 1)
})
