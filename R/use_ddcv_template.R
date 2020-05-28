#' Use template file from package
#'
#' @param file_name Name of file from templates to use: e.g. `cv.rmd`.
#' @param params Parameters used to fill in `whisker` template
#' @param output_file_name Name of file after being placed.
#' @param output_dir Directory location for output to be placed in.
#' @param create_output_dir If the requested output directory is missing should it be created?
#' @param warn_about_no_change If there is no change between the new file and what was already there, should a warning be issued?
#' @param open_after_making Should the file be opened after it has been written?
#'
#' @return NULL
use_ddcv_template <- function(
  file_name,
  params = NULL,
  output_file_name = file_name,
  output_dir = getwd(),
  create_output_dir = FALSE,
  warn_about_no_change = TRUE,
  open_after_making = FALSE){
  output_dir_missing <- !fs::dir_exists(output_dir)

  if(output_dir_missing & create_output_dir){
    fs::dir_create(output_dir)
  } else
  if(output_dir_missing & !create_output_dir) {
    stop(glue::glue("The requested output directory: {output_dir} doesn't exist. Either set create_output_dir = TRUE or manually make directory."))
  }


  template_loc <- fs::path(system.file("templates/", package = "datadrivencv"), file_name)
  output_loc <- fs::path(output_dir, output_file_name)

  template_text <- readr::read_file(template_loc)

  if(!is.null(params)){
    template_text <- whisker::whisker.render(template_text, data = params)
  }

  # Check if file exists already
  already_exists <- fs::file_exists(output_loc)
  if(already_exists){
    # Check if the two files are identical
    no_changes_made <- readr::read_file(output_loc) == template_text

    if(no_changes_made & warn_about_no_change){
      warning(glue::glue("{file_name} already exists and there are no differences with the current version."))
    }
  }

  readr::write_file(template_text, output_loc)

  # Open the file if requested
  if(open_after_making){
    if (rstudioapi::isAvailable() && rstudioapi::hasFun("navigateToFile")) {
      rstudioapi::navigateToFile(output_loc)
    } else {
      utils::file.edit(output_loc)
    }
  }
}
