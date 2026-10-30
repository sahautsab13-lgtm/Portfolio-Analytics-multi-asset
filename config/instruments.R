# Example NSE instruments. Availability must be checked with Yahoo Finance at runtime.
# These are suggestions only; users may add any Yahoo Finance-compatible NSE ticker.
instrument_registry <- data.frame(
  ticker = c("RELIANCE.NS", "TCS.NS", "INFY.NS", "NIFTYBEES.NS", "GOLDBEES.NS", "LIQUIDBEES.NS"),
  name = c("Reliance Industries", "Tata Consultancy Services", "Infosys", "Nippon India ETF Nifty BeES", "Nippon India ETF Gold BeES", "Nippon India ETF Liquid BeES"),
  asset_class = c("Equity", "Equity", "Equity", "Equity", "Gold", "Debt"),
  notes = c("NSE equity", "NSE equity", "NSE equity", "Equity ETF", "Gold ETF", "Liquid/money-market ETF; not a broad bond-market proxy"),
  stringsAsFactors = FALSE
)

asset_classes <- c("Equity", "Debt", "Gold")
