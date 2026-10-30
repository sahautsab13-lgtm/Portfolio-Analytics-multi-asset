# Multi-Asset Portfolio Allocation & Risk Analytics System
## User manual, test guide and presentation notes

## 1. What this application does

This Shiny application is an educational portfolio-management tool for INR-denominated portfolios. It lets a user:

- select NSE/Yahoo Finance instruments from Equity, Debt and Gold;
- set a total investment amount and a two-level allocation;
- download historical daily prices dynamically from Yahoo Finance;
- calculate historical return, risk, correlation, drawdown and diversification measures; and
- compare the diversified portfolio with an equity-only version of the selected equity instruments.

It does **not** forecast prices, recommend securities, guarantee returns or provide personalized investment advice.

## 2. Before testing

1. Open the project in RStudio and open `app.R`.
2. Run the app with **Run App**, or run `shiny::runApp()` in the Console.
3. Confirm that the tabs Dashboard, Portfolio Builder, Assets & Instruments, Risk Analysis and Comparison are visible.
4. Open **Portfolio Builder** before loading market data. The app starts with a verified example portfolio so there is something meaningful to test.

> Yahoo Finance is a third-party source, not an official NSE data feed. Data availability can change between runs.

## 3. Quick demonstration scenario

Use this scenario for a reliable first test and for a classroom demonstration.

| Setting | Value |
|---|---:|
| Total investment | ₹1,000,000 |
| Date range | 29 Oct 2024 to 29 Oct 2026 |
| Annual risk-free rate | 6.00% |
| Equity allocation | 50% |
| Debt allocation | 30% |
| Gold allocation | 20% |
| Equity instrument | `RELIANCE.NS`, 100% of Equity |
| Debt instrument | `LIQUIDBEES.NS`, 100% of Debt |
| Gold instrument | `GOLDBEES.NS`, 100% of Gold |

### Steps

1. In **Portfolio Builder**, enter the values above.
2. Check that the green validation message says that effective weights sum to 100%.
3. Confirm that the allocation table shows:

| Instrument | Effective portfolio weight | Rupee allocation |
|---|---:|---:|
| RELIANCE.NS | 50% | ₹500,000 |
| LIQUIDBEES.NS | 30% | ₹300,000 |
| GOLDBEES.NS | 20% | ₹200,000 |

4. Click **Load / refresh market data** and wait for the download to finish.
5. Open each remaining tab and explain the result using the notes below.

### Illustrative output for this scenario

These values were calculated from a live Yahoo Finance download on 30 Oct 2026, using 493 common daily returns from 30 Oct 2024 to 28 Oct 2026. Your values may differ slightly as Yahoo corrects historical data or the selected dates change.

| Portfolio metric | Illustrative result | Plain-English meaning |
|---|---:|---|
| Annualized arithmetic return | 4.8% | Average daily historical return scaled to 252 trading days; it is not a forecast. |
| Annualized volatility | 11.9% | Historical annualized variation in portfolio returns; higher means more uncertainty. |
| Annualized variance | 0.0142 | Volatility squared; used in the covariance-based risk calculation. |
| CAGR | 4.1% | Compounded historical growth rate over the actual period. |
| Maximum drawdown | -12.7% | Largest historical fall from a previous portfolio peak. |
| Sharpe ratio | -0.10 | Historical excess return relative to 6% risk-free rate, per unit of volatility. |

The negative Sharpe ratio in this example is not an app error. It means this particular historical period did not exceed the chosen 6% risk-free rate after accounting for total volatility.

## 4. How to use every section

### Dashboard

Use this as the executive summary.

- **Investment:** total INR amount entered by the user.
- **Annualized return:** arithmetic historical return, annualized from daily returns.
- **Annualized volatility:** annualized risk measure.
- **Sharpe ratio:** excess annualized return divided by annualized volatility.
- **Historical growth:** how ₹1 would have grown historically under the stated daily-rebalancing assumption.
- **Allocation by asset class:** final Equity/Debt/Gold split.

Say: “This dashboard summarizes the portfolio’s historical performance and risk. It does not predict future performance.”

### Portfolio Builder

This is the input and validation area.

1. Enter the total investment amount in INR.
2. Choose the historical date range and risk-free rate.
3. Add an example instrument or type a valid Yahoo ticker such as `TCS.NS`.
4. Select its asset class honestly. For example, a gold ETF belongs under Gold, not Equity.
5. Set strategic asset-class allocations. Active classes must total exactly 100%.
6. Set the within-class allocation for each selected instrument. Instruments inside each class must total exactly 100%.
7. Click **Load / refresh market data**.

If Equity is 50% and Reliance is 100% within Equity, its effective portfolio weight is `50% × 100% = 50%`. If two equities received 60% and 40% within a 50% Equity class, their effective portfolio weights would be 30% and 20%.

### Assets & Instruments

- **Normalized performance chart:** all selected prices start at 100, making instruments with very different price levels comparable.
- **Instrument metrics:** daily mean return, daily variance, daily volatility, annualized return, annualized volatility and cumulative return.
- **Market-data coverage:** downloaded observations, last available date and number of common observations remaining after alignment.

Say: “The application only calculates multi-asset returns on dates shared by all instruments. It does not invent missing prices.”

### Risk Analysis

- **Correlation heatmap:** values range from -1 to +1. Lower-than-perfect correlation can reduce portfolio risk, but does not eliminate it.
- **Risk summary:** annualized return, volatility, variance, CAGR, maximum drawdown and Sharpe ratio.
- **Diversification statement:** average pairwise correlation gives a simple indication of whether assets are moving together.

Example interpretation: a debt/liquid-market ETF may have much lower volatility than equity or gold; including it can reduce total portfolio volatility. That does not mean it is risk-free.

### Comparison

This compares the diversified portfolio with a hypothetical **equity-only portfolio** made from the selected equity instruments.

It is not an index benchmark. If no equity instrument is selected, the comparison is unavailable. Explain that the comparison asks: “Historically, how did adding the selected Debt and Gold exposure change the risk and growth profile relative to keeping only Equity?”

## 5. Financial calculations explained

### Daily return

For each instrument, the app uses daily simple returns:

`Daily return = (current adjusted price / previous adjusted price) - 1`

Adjusted closing prices are used whenever Yahoo provides them. If adjusted prices are unavailable, the app uses closing prices and reports the provider limitation in the app documentation.

### Individual-instrument metrics

- **Mean daily return:** average of daily simple returns.
- **Daily variance:** spread of daily returns around the mean, squared.
- **Daily standard deviation:** square root of variance.
- **Annualized arithmetic return:** `mean daily return × 252`.
- **Annualized volatility:** `daily standard deviation × √252`.
- **Cumulative performance:** product of `(1 + daily return)` across the selected dates, minus 1.

The number 252 approximates trading days in a year.

### Two-level allocation and effective weights

`Effective instrument weight = asset-class allocation × within-class instrument allocation`

All asset-class weights must add to 100%, and all effective instrument weights must also add to 100%.

### Portfolio return and variance

The app aligns all selected instruments on common valid dates, then assumes the target weights are restored each day (daily rebalancing).

`Portfolio daily return = Σ(weight of instrument i × return of instrument i)`

The covariance matrix represents each asset’s own variability and how assets move together. Portfolio annualized variance is:

`Portfolio variance = w' × (daily covariance matrix × 252) × w`

Portfolio annualized volatility is the square root of annualized variance.

### CAGR, maximum drawdown and Sharpe ratio

- **CAGR:** the realized compounded historical growth rate over the period. It is different from annualized arithmetic return.
- **Maximum drawdown:** largest percentage decline from an earlier portfolio peak.
- **Sharpe ratio:** `(annualized portfolio return - annual risk-free rate) / annualized volatility`.

## 6. What to test tomorrow

Use this checklist and take screenshots of the results that matter.

- [ ] Run the starter scenario and verify the allocation table totals 100%.
- [ ] Change the investment from ₹1,000,000 to ₹500,000. Weights and metrics should stay the same; rupee allocations should halve.
- [ ] Change Equity/Debt/Gold to 70%/20%/10%. Effective weights, charts and risk metrics should update after refreshing data.
- [ ] Add `TCS.NS` as Equity and change Equity’s within-class allocations to Reliance 50% and TCS 50%.
- [ ] Remove an instrument. The app should require the affected allocation totals to be valid again.
- [ ] Enter an invalid ticker such as `NOT_A_REAL_NSE_TICKER.NS`, click load, and confirm a clear failure message appears rather than fabricated data.
- [ ] Select a very short date range and confirm the insufficient-common-observations warning.
- [ ] Open the correlation heatmap, data coverage table and portfolio comparison tab.

## 7. Limitations and assumptions to state clearly

1. Yahoo Finance is a third-party historical source, not an official NSE feed.
2. Historical results do not guarantee future returns.
3. The portfolio calculation assumes daily rebalancing to target weights.
4. Brokerage, taxes, transaction costs, slippage, liquidity constraints and market impact are excluded.
5. The risk-free rate is user-entered; changing it changes the Sharpe ratio.
6. Using common trading dates can reduce the available sample, especially when instruments have different listing histories.
7. `LIQUIDBEES.NS` is a liquid/money-market ETF, not a broad bond-market proxy.
8. The app does not provide real-time prices, prediction, optimization, trading signals or investment advice.

## 8. Short presentation script

“This project is a multi-asset portfolio allocation and risk analytics system built in R Shiny. A user can select NSE/Yahoo Finance instruments across Equity, Debt and Gold, set a total INR investment and allocate at two levels: first by asset class and then by instrument within that class. The application downloads historical daily prices dynamically, aligns common trading dates and uses daily simple returns. It calculates annualized arithmetic return, covariance-based volatility, CAGR, maximum drawdown, Sharpe ratio and correlations. The purpose is to demonstrate how diversification changes a portfolio’s historical risk and return characteristics. It is an educational analysis tool, not an investment recommendation, and it clearly discloses data-source and methodology limitations.”

## 9. Likely questions and concise answers

1. **Why use more than one asset class?** Different asset classes can have different return patterns and correlations, which may reduce overall portfolio volatility.
2. **Why must allocations total 100%?** The calculation represents the complete investment amount; otherwise weights would not describe a full portfolio.
3. **Why use adjusted prices?** They better account for corporate actions where the provider supplies adjusted data.
4. **Why use covariance?** Portfolio risk depends on both individual volatility and the way assets move together.
5. **What is the difference between CAGR and annualized return?** CAGR compounds actual historical returns; annualized arithmetic return scales the mean daily return and does not compound it.
6. **What does a negative Sharpe ratio indicate?** The historical return was below the chosen risk-free rate after considering volatility.
7. **Why align common dates?** It avoids calculating a portfolio return from mismatched days or invented prices.
8. **Why daily rebalancing?** It keeps weights constant for a simple, consistent first-version portfolio simulation.
9. **Is LIQUIDBEES the same as a bond index?** No. It is a liquid/money-market ETF and should not be described as broad bond-market exposure.
10. **Can this app predict the best stock?** No. It analyzes historical data only and makes no prediction or recommendation.
