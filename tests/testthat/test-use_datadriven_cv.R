test_that("Addition of all files works", {

  # Make a temp directory for placing files
  temp_dir <- fs::dir_create(fs::path(tempdir(), "test_dir"))

  datadrivencv::use_datadriven_cv(
    full_name = "Testing McTester",
    data_location = "here/be/my/data/",
    output_dir = temp_dir,
    open_files = FALSE
  )
  expect_true(
    all(c("cv.rmd", "dd_cv.css", "render_cv.r", "cv_printing_functions.r") %in% list.files(temp_dir))
  )

  # Clean up temp dir
  fs::dir_walk(temp_dir, fs::file_delete)
})


test_that("Addition of subset of files", {

  # Make a temp directory for placing files
  temp_dir <- fs::dir_create(fs::path(tempdir(), "test_dir"))

  datadrivencv::use_datadriven_cv(
    full_name = "Testing McTester",
    data_location = "here/be/my/data/",
    output_dir = temp_dir,
    which_files = c("render_cv.r", "cv_printing_functions.r"),
    open_files = FALSE
  )

  expect_true(
    all(c("render_cv.r", "cv_printing_functions.r") %in% list.files(temp_dir))
  )

  expect_false("cv.rmd" %in% list.files(temp_dir))
  expect_false("dd_cv.css" %in% list.files(temp_dir))
  # Clean up temp dir
  fs::dir_walk(temp_dir, fs::file_delete)
})


test_that("Warns when trying to update a file with no change", {

  # Make a temp directory for placing files
  temp_dir <- fs::dir_create(fs::path(tempdir(), "test_dir"))


  # First dump all files into directory
  datadrivencv::use_datadriven_cv(
    full_name = "Testing McTester",
    data_location = "here/be/my/data/",
    output_dir = temp_dir,
    which_files = "all",
    open_files = FALSE
  )

  # Then try an update of the rmd file that has no changes
  expect_warning(
    datadrivencv::use_datadriven_cv(
      full_name = "Testing McTester",
      data_location = "here/be/my/data/",
      output_dir = temp_dir,
      which_files = c("cv.rmd"),
      open_files = FALSE
    ),
    "cv.rmd already exists and there are no differences with the current version.",
    fixed = TRUE
  )

  # Finally, do an update with a different name which should not give a warning
  testthat::expect_silent(
    datadrivencv::use_datadriven_cv(
      full_name = "Testing McTester the second",
      data_location = "here/be/my/data/",
      output_dir = temp_dir,
      which_files = c("cv.rmd"),
      open_files = FALSE
    )
  )

  # Clean up temp dir
  fs::dir_walk(temp_dir, fs::file_delete)
})


test_that("Addition of all data csvs works", {

  # Make a temp directory for placing files
  temp_dir <- fs::dir_create(fs::path(tempdir(), "test_dir"))

  # Wont make a new directory for you if you dont want it to
  expect_error(
    datadrivencv::use_csv_data_storage(
      folder_name = fs::path(temp_dir, "csv_data"),
      create_output_dir = FALSE
    ),
    paste(
      "The requested output directory:",
      fs::path(temp_dir, "csv_data"),
      "doesn't exist. Either set create_output_dir = TRUE or manually make directory."
    ),
    fixed = TRUE
  )

  # Will make directory for you if you want it to
  datadrivencv::use_csv_data_storage(
    folder_name = fs::path(temp_dir, "csv_data"),
    create_output_dir = TRUE
  )

  expect_true(
    all(c("entries.csv", "text_blocks.csv", "language_skills.csv","contact_info.csv" ) %in% list.files(fs::path(temp_dir, "csv_data")))
  )

  # Clean up temp dir
  fs::dir_walk(temp_dir, fs::file_delete)
})

