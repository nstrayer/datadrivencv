#' Use CSVs for storing data
#'
#' Sets up examples of the four CSVs needed for building CV
#'
#'
#' @param folder_name Name of the folder you want csvs stored in relative to current working directory
#' @inheritParams use_ddcv_template
#'
#' @return A new folder `<folder_name>/` with `entries.csv`, `text_blocks.csv`, `language_skills.csv`, and `contact_info.csv` in it.
#'   working directory.
#'
#' @examples
#'
#' # Make a temp directory for placing files
#' # This would be a real location for a typical situation
#' temp_dir <- fs::dir_create(fs::path(tempdir(), "cv_w_csvs"))
#'
#' datadrivencv::use_csv_data_storage(
#'   folder_name = fs::path(temp_dir, "csv_data"),
#'   create_output_dir = TRUE
#' )
#'
#' list.files(fs::path(temp_dir, "csv_data"))
#'
#' @export
use_csv_data_storage <- function(folder_name = "data", create_output_dir = TRUE){

  for(csv_file in c("entries.csv", "text_blocks.csv", "language_skills.csv","contact_info.csv" )){
    use_ddcv_template(
      file_name = csv_file,
      output_dir = folder_name,
      create_output_dir = create_output_dir,
      warn_about_no_change = TRUE
    )
  }

  print(paste("Copied CSVs to ", folder_name))
}
