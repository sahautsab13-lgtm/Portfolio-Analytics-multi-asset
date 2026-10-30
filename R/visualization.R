currency_inr <- function(x) paste0("₹", format(round(x, 0), big.mark = ",", scientific = FALSE))

growth_plot <- function(dates, portfolio_growth, benchmark_growth = NULL) {
  d <- data.frame(date = as.Date(dates), Diversified = as.numeric(portfolio_growth))
  chart <- plotly::plot_ly(d, x = ~date, y = ~Diversified, type = "scatter", mode = "lines", name = "Diversified")
  if (!is.null(benchmark_growth)) chart <- plotly::add_lines(chart, y = benchmark_growth, name = "Equity-only")
  plotly::layout(chart, yaxis = list(title = "Growth of ₹1"), xaxis = list(title = "Date"))
}

correlation_heatmap <- function(correlation) {
  plotly::plot_ly(x = colnames(correlation), y = rownames(correlation), z = correlation, type = "heatmap",
    colors = "RdBu", zmin = -1, zmax = 1, colorbar = list(title = "Correlation"))
}
