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
#' \dontrun{
#'   use_csv_data_storage(folder_name = "my_data")
#' }
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
