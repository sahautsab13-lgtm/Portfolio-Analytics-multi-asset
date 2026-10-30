library(testthat)
source("config/instruments.R")
invisible(lapply(list.files("R", pattern = "\\.R$", full.names = TRUE), source))
test_dir("tests/testthat")
