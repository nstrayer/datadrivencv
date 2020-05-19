load_data_from_googlesheets <- function(data_location, sheet_is_publicly_readable = TRUE){

  if(sheet_is_publicly_readable){
    # This tells google sheets to not try and authenticate. Note that this will only
    # work if your sheet has sharing set to "anyone with link can view"
    googlesheets4::sheets_deauth()
  } else {
    # My info is in a public sheet so there's no need to do authentication but if you want
    # to use a private sheet, then this is the way you need to do it.
    # designate project-specific cache so we can render Rmd without problems
    options(gargle_oauth_cache = ".secrets")
  }

  data <- list()



  data$position_data <- googlesheets4::read_sheet(data_location, sheet = "positions") %>%
    # Google sheets loves to turn columns into list ones if there are different types
    dplyr::mutate_if(is.list, purrr::map_chr, as.character)

  data$skills        <- googlesheets4::read_sheet(data_location, sheet = "language_skills")
  data$text_blocks   <- googlesheets4::read_sheet(data_location, sheet = "text_blocks")
  data$contact_info  <- googlesheets4::read_sheet(data_location, sheet = "contact_info", skip = 1)

  data
}
