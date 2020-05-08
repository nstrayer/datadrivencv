#' Use Data Driven CV template
#'
#' Sets up the `.Rmd` file for a data-driven cv in current working directory.
#' Also adds css file for current CV so style can be custommized.
#'
#'
#'
#' @param full_name Your full name, used in title of document and header
#' @param data_loc Path of the spreadsheets holding all your data. This can be
#'   either a URL to a google sheet with multiple sheets containing the four
#'   data types or a path to a folder containing four `.csv`s with the neccesary
#'   data.
#' @param pdf_loc What location will the PDF of this CV be hosted at?
#' @param html_loc What location will the HTML version of this CV be hosted at?
#' @param source_loc Where is the code to build your CV hosted?
#' @param logo_loc Link (local or remote) to the logo image for the upper right corner of your CV.
#'
#' @return `cv.Rmd` and `dd_cv.css` written to the current working directory.
#'
#' @examples
#'
#' \dontrun{
#'   use_datadriven_cv(
#'     full_name = "Nick Strayer",
#'     data_loc = "https://docs.google.com/spreadsheets/d/14MQICF2F8-vf8CKPF1m4lyGKO6_thG-4aSwat1e2TWc",
#'     pdf_loc = "https://github.com/nstrayer/cv/raw/master/strayer_cv.pdf",
#'     html_loc = "nickstrayer.me/cv/",
#'     source_loc = "https://github.com/nstrayer/cv",
#'     logo_loc = "https://www.r-project.org/logo/Rlogo.png"
#'   )
#' }
#'
#' @export
use_datadriven_cv <- function(full_name = "Sarah Arcos",
                              data_loc = system.file("sample_data/", package = "datadrivencv"),
                              pdf_loc = "https://github.com/nstrayer/cv/raw/master/strayer_cv.pdf",
                              html_loc = "nickstrayer.me/datadrivencv/",
                              source_loc = "https://github.com/nstrayer/datadrivencv",
                              logo_loc = system.file("figs/logo.png", package = "datadrivencv")){

  # Sets the main Rmd template
  usethis::use_template(
    template = "cv.Rmd",
    package = "datadrivencv",
    data = list(
      full_name = full_name,
      data_loc = data_loc,
      pdf_loc = pdf_loc,
      html_loc = html_loc,
      source_loc = source_loc,
      logo_loc = logo_loc
    )
  )

  # Places the css as well
  usethis::use_template(
    template = "dd_cv.css",
    package = "datadrivencv"
  )
}

use_datadriven_cv()
