test_that("Rendering to HTML works", {
  # Make a temp directory for placing files
  # and make sure it's empty
  temp_dir <- fs::dir_create(fs::path(tempdir(), "test_dir"))


  # Setup data
  data_loc <- fs::path(temp_dir, "csv_data")
  datadrivencv::use_csv_data_storage(
    folder_name = data_loc,
    create_output_dir = TRUE
  )

  # Setup files
  datadrivencv::use_datadriven_cv(
    full_name = "Testing McTester",
    data_location = paste0(data_loc, "/"),
    output_dir = temp_dir,
    open_files = FALSE,
    use_network_logo = TRUE
  )

  # Knit the HTML version
  html_knit_res <- rmarkdown::render(fs::path(temp_dir, "cv.rmd"),
                                     params = list(pdf_mode = FALSE),
                                     output_file = fs::path(temp_dir, "cv.html"),
                                     quiet = TRUE)

  expect_true(fs::file_exists(html_knit_res))

  # Knit version for PDF
  pdf_knit_res <-rmarkdown::render(fs::path(temp_dir, "cv.rmd"),
                                   params = list(pdf_mode = TRUE),
                                   output_file = fs::path(temp_dir, "cv_4_pdf.html"),
                                   quiet = TRUE)

  has_link_section <- function(html_text){
    stringr::str_detect(
      html_text,
      stringr::fixed("<div id=\"links\" class=\"section level2\" data-icon=\"link\">
<h2>Links</h2>")
    )
  }
  # Make sure that the output has a links section at the end of it
  expect_true(has_link_section(readr::read_file(pdf_knit_res)))

  # Also make sure the html output doesn't have the links section
  expect_false(has_link_section(readr::read_file(html_knit_res)))

  # Clean up temp dir
  fs::dir_walk(temp_dir, fs::file_delete)
})
