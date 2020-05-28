#' Use Data Driven CV template
#'
#' Sets up the `.Rmd` file for a data-driven cv in current working directory.
#' Also adds css file for current CV so style can be custommized.
#'
#'
#'
#' @param full_name Your full name, used in title of document and header
#' @param data_location Path of the spreadsheets holding all your data. This can
#'   be either a URL to a google sheet with multiple sheets containing the four
#'   data types or a path to a folder containing four `.csv`s with the neccesary
#'   data. See \code{\link{use_csv_data_storage()}} for help setting up these
#'   `.csv`s.
#' @param pdf_location What location will the PDF of this CV be hosted at?
#' @param html_location What location will the HTML version of this CV be hosted
#'   at?
#' @param source_location Where is the code to build your CV hosted?
#' @param open_files Should the added files be opened after creation?
#' @param which_files What files should be placed? Takes a vector of possible
#'   values `c("cv.Rmd", "dd_cv.css", "render_cv.R", "CV_printing_functions.R")`
#'   or `"all"` for everything. This can be used to incrementally update the
#'   printing functions or CSS without loosing customizations you've made to
#'   other files.
#' @param use_network_logo Should logo be an interactive network based on your
#'   CV data? Note that this uses the function
#'   \code{\link{build_network_logo()}} so will introduce a dependency on this
#'   package.
#'
#' @return `cv.Rmd`, `dd_cv.css`, `render_cv.R`, and `CV_printing_functions.R`
#'   written to the current working directory.
#'
#' @examples
#'
#' \dontrun{
#'   use_datadriven_cv(
#'     full_name = "Nick Strayer",
#'     data_location = "https://docs.google.com/spreadsheets/d/14MQICF2F8-vf8CKPF1m4lyGKO6_thG-4aSwat1e2TWc",
#'     pdf_location = "https://github.com/nstrayer/cv/raw/master/strayer_cv.pdf",
#'     html_location = "nickstrayer.me/cv/",
#'     source_location = "https://github.com/nstrayer/cv"
#'   )
#' }
#'
#' @export
use_datadriven_cv <- function(full_name = "Sarah Arcos",
                              data_location = system.file("sample_data/", package = "datadrivencv"),
                              pdf_location = "https://github.com/nstrayer/cv/raw/master/strayer_cv.pdf",
                              html_location = "nickstrayer.me/datadrivencv/",
                              source_location = "https://github.com/nstrayer/datadrivencv",
                              which_files = "all",
                              use_network_logo = TRUE,
                              open_files = TRUE){

  if(which_files == "all"){
    which_files <- c("cv.Rmd", "dd_cv.css", "render_cv.R", "CV_printing_functions.R")
  }

  if("cv.Rmd" %in% which_files){
    # Sets the main Rmd template
    usethis::use_template(
      template = "cv.Rmd",
      package = "datadrivencv",
      data = list(
        full_name = full_name,
        data_location = data_location,
        pdf_location = pdf_location,
        html_location = html_location,
        source_location = source_location,
        use_network_logo = use_network_logo
      ),
      open = open_files
    )
  }

  if("dd_cv.css" %in% which_files){
    # Place the css as well
    usethis::use_template(
      template = "dd_cv.css",
      package = "datadrivencv",
      open = open_files
    )
  }

  if("render_cv.R" %in% which_files){
    usethis::use_template(
      template = "render_cv.R",
      package = "datadrivencv",
      open = open_files
    )
  }

  if("CV_printing_functions.R" %in% which_files){
    usethis::use_template(
      template = "CV_printing_functions.R",
      package = "datadrivencv"
    )
  }

}
