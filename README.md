# Multi-Asset Portfolio Allocation & Risk Analytics System

An educational R Shiny application for constructing an INR-denominated, multi-asset portfolio and examining its historical return, risk, correlation and diversification characteristics. It supports Equity, Debt/Fixed Income and Gold instruments listed on Yahoo Finance (including NSE tickers such as `RELIANCE.NS`). It is not investment advice and makes no return predictions.

## Problem statement

Investors need a transparent way to see how strategic allocation across asset classes and the selection of individual instruments affect historical portfolio risk. This project lets a user create a portfolio dynamically, choose a date range and assess the resulting historical evidence without maintaining a manually edited price CSV.

## Features

- Dynamic addition/removal of Yahoo Finance tickers and asset-class labels.
- Two-level allocation: strategic asset-class allocation and within-class instrument allocation.
- Rupee allocation amounts, effective weights and allocation validation.
- Downloaded daily adjusted close data where Yahoo provides it, in-session caching, failed-download messages and coverage reporting.
- Common-date alignment only; no missing prices are invented.
- Individual daily-return/annualized metrics, portfolio return, volatility, variance, CAGR, maximum drawdown and configurable-risk-free-rate Sharpe ratio.
- Interactive growth, normalized-performance, allocation and correlation charts.
- Comparison with a hypothetical equity-only portfolio formed from the user’s selected equity instruments.

## Architecture

```
app.R                 # app entry point
ui.R / server.R       # Shiny dashboard and reactive wiring
config/instruments.R  # extensible example registry
R/data_fetch.R        # Yahoo retrieval and cache
R/data_validation.R   # integrity checks
R/data_processing.R   # date alignment and coverage
R/allocation_logic.R  # two-level allocations
R/returns_calculation.R / R/portfolio_metrics.R
R/visualization.R
tests/testthat/       # unit tests
```

## Data source

The app calls Yahoo Finance through `quantmod`; it is a third-party provider, not an official NSE feed. Yahoo availability can change and every ticker is validated at download time. Suggested registry entries are examples rather than a claim of current availability. `LIQUIDBEES.NS` is labelled as a liquid/money-market ETF and must not be interpreted as a broad bond-market proxy. No data are simulated or substituted on download failure.

## Financial methodology

Daily simple return: `r_t = P_t / P_(t-1) - 1`.

Annualized arithmetic return: `mean(r) × 252`; annualized volatility: `sd(r) × sqrt(252)`.

Effective instrument weight: `asset-class weight × within-class weight`.

Portfolio variance: `w' × Cov_daily × 252 × w`; annualized volatility is its square root. CAGR is computed from realized compounded daily returns and is intentionally shown separately from annualized arithmetic return. Maximum drawdown is the largest fall from a prior portfolio wealth peak. Sharpe ratio uses the user-entered annual risk-free rate.

Returns use shared valid dates across all instruments and constant target weights, representing daily rebalancing.

## Install and run

From the project folder, run:

```r
source("requirements.R")
shiny::runApp()
```

Run calculation tests after packages are installed:

```r
source("tests/testthat.R")
```

## Assumptions and limitations

- Historical performance is not a guarantee or recommendation.
- Daily rebalancing is assumed; brokerage, taxes, transaction costs, slippage and liquidity constraints are excluded.
- Results depend on Yahoo Finance data quality and common-date data loss. The app warns if fewer than 30 shared daily returns exist.
- The equity-only comparison is an investable-instrument comparison, not an index benchmark.
- This first version excludes real-time quotes, forecasting, optimization, VaR/CVaR and automated trading.

## College report methodology

1. Collect user-selected NSE/Yahoo tickers and classify each by asset class.
2. Download daily historical adjusted prices and validate availability.
3. Align all instruments to their shared valid trading dates and calculate daily simple returns.
4. Convert strategic and within-class allocations to effective portfolio weights.
5. Calculate return, covariance-based risk, correlation, drawdown, CAGR and Sharpe ratio.
6. Present a diversified-versus-equity-only historical comparison and disclose assumptions.

## Likely viva questions

1. **Why use adjusted close?** It better reflects corporate actions such as splits and distributions when the provider supplies it.
2. **Why annualize with 252?** It approximates the number of trading days in a year.
3. **Arithmetic annualized return versus CAGR?** Arithmetic return scales the average daily return; CAGR is the realized compound growth rate.
4. **Why use a covariance matrix?** It captures both each asset’s variability and how assets move together.
5. **How does correlation affect diversification?** Less-than-perfect correlation can reduce combined volatility; it cannot remove risk.
6. **What is the two-level allocation?** Class weights set strategic exposure, and within-class weights divide that exposure among instruments.
7. **Why align common dates?** It prevents returns from being compared across different trading days or from fabricated values.
8. **What is the daily-rebalancing assumption?** The portfolio is reset to target weights every day when calculating historical portfolio returns.
9. **What does maximum drawdown measure?** The largest historical peak-to-trough loss.
10. **What does Sharpe ratio measure?** Excess return per unit of total volatility, relative to the chosen risk-free rate.
11. **Why use Yahoo Finance?** It is convenient for an educational prototype, but is not an official exchange data source.
12. **Why is this portfolio management?** It combines allocation, diversification, risk measurement and performance assessment across asset classes.

