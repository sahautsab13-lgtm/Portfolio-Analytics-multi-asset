validate_allocations <- function(instruments, class_weights, instrument_weights, tolerance = 1e-8) {
  active <- unique(instruments$asset_class)
  if (!all(active %in% names(class_weights))) return("Every active asset class needs an allocation.")
  cw <- class_weights[active]
  if (any(!is.finite(cw)) || any(cw < 0)) return("Asset-class allocations must be non-negative numbers.")
  if (abs(sum(cw) - 100) > tolerance) return("Active asset-class allocations must sum to 100%.")
  for (cls in active) {
    ids <- instruments$ticker[instruments$asset_class == cls]
    iw <- instrument_weights[ids]
    if (length(iw) != length(ids) || any(!is.finite(iw)) || any(iw < 0) || abs(sum(iw) - 100) > tolerance) {
      return(sprintf("Instrument allocations within %s must be non-negative and sum to 100%%.", cls))
    }
  }
  NULL
}

effective_weights <- function(instruments, class_weights, instrument_weights) {
  weights <- vapply(seq_len(NROW(instruments)), function(i) {
    cls <- instruments$asset_class[i]; ticker <- instruments$ticker[i]
    class_weights[[cls]] * instrument_weights[[ticker]] / 100
  }, numeric(1))
  names(weights) <- instruments$ticker
  weights
}

allocation_table <- function(instruments, class_weights, instrument_weights, investment) {
  w <- effective_weights(instruments, class_weights, instrument_weights)
  transform(instruments, class_weight_pct = unname(class_weights[asset_class]), instrument_weight_pct = unname(instrument_weights[ticker]),
    effective_weight_pct = unname(w[ticker]), amount_inr = unname(w[ticker]) * investment / 100)
}
