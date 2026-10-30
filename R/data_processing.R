align_price_series <- function(successes) {
  if (!length(successes)) return(NULL)
  series <- lapply(successes, `[[`, "data")
  merged <- Reduce(function(a, b) merge(a, b, join = "inner"), series)
  merged <- merged[stats::complete.cases(merged), ]
  if (!NROW(merged)) return(NULL)
  merged
}

coverage_summary <- function(successes, aligned_prices) {
  if (!length(successes)) return(data.frame())
  data.frame(
    ticker = names(successes),
    downloaded_observations = vapply(successes, function(x) NROW(x$data), integer(1)),
    last_available = vapply(successes, function(x) as.character(tail(zoo::index(x$data), 1)), character(1)),
    common_observations = if (is.null(aligned_prices)) 0L else NROW(aligned_prices),
    stringsAsFactors = FALSE
  )
}
