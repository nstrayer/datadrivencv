#' Use CSVs for storing data
#'
#' Sets up examples of the four CSVs needed for building CV
#'
#'
#' @param folder_name Name of the folder you want csvs stored in
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
use_csv_data_storage <- function(folder_name = "data"){

  # Setup the folder for holding CSVs
  data_folder <- fs::dir_create(folder_name)

  copy_csv <- function(csv_name){
    fs::file_copy(fs::path(system.file("templates/", package = "datadrivencv"), csv_name),
                  fs::path(data_folder, csv_name))
  }

  copy_csv("entries.csv")
  copy_csv("text_blocks.csv")
  copy_csv("language_skills.csv")
  copy_csv("contact_info.csv")

  print(paste("Copied CSVs to ", data_folder))
}
