library(here)


datadrivencv::use_datadriven_cv(
  full_name = "Testing McTester",
  # data_location = "https://docs.google.com/spreadsheets/d/1SC8dKPlPZDA1MECZr8xlJPitjWQ3AV4eXrPvnlNv7m8/",
  data_location = "https://docs.google.com/spreadsheets/d/14MQICF2F8-vf8CKPF1m4lyGKO6_thG-4aSwat1e2TWc",
  output_dir = here("tests/date_options"),
  open_files = FALSE,
  which_files = "all"
  # which_files = c("cv_printing_functions.r")
)
