required_packages <- c("shiny", "bslib", "bsicons", "plotly", "quantmod", "xts", "zoo", "DT", "testthat", "scales")
missing <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
