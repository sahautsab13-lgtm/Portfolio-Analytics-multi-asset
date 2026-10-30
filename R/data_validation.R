validate_instruments <- function(instruments) {
  required <- c("ticker", "asset_class")
  if (!all(required %in% names(instruments))) return("Instrument data is missing ticker or asset class.")
  if (!NROW(instruments)) return("Add at least one instrument.")
  if (any(!instruments$asset_class %in% asset_classes)) return("Each instrument must use a supported asset class.")
  if (anyDuplicated(toupper(instruments$ticker))) return("Each ticker can be added only once.")
  if (any(!nzchar(trimws(instruments$ticker)))) return("Ticker symbols cannot be blank.")
  NULL
}

validate_common_returns <- function(returns, min_observations = 30L) {
  if (is.null(returns) || NROW(returns) < min_observations) {
    return(sprintf("Only %s common daily return observations are available; at least %s are required.", if (is.null(returns)) 0 else NROW(returns), min_observations))
  }
  if (any(!is.finite(as.matrix(returns)))) return("Aligned returns contain invalid values.")
  NULL
}
