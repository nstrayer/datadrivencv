
link_header <- "
Links {data-icon=link}
--------------------------------------------------------------------------------

<br>


"

pdf_style <- "
<style>
:root{
  --decorator-outer-offset-left: -6.5px;
}
</style>"


default_position_entry_template <-"
### {title}

{loc}

{institution}

{timeline}

{description_bullets}
\n\n\n"


# Tests if the end date is set as current, via values in the current_names vector
date_is_current <- function(date){
  current_names <- c("current", "now", "")
  tolower(date) %in% current_names
}

# This year is assigned to the end date of "current" events to make sure they get sorted later.
future_year <- lubridate::year(lubridate::ymd(Sys.Date())) + 10


#' R6 Class to print components of CV from data
#'
#' This class is initiated at the head of your CV or Resume Rmarkdown file and
#' then through various `print_*` methods, builds the various components.
#' @export
CV_Printer <- R6::R6Class("CV_Printer", list(
  #' @field position_data dataframe of positions by row
  position_data = dplyr::tibble(),
  #' @field position_data dataframe of positions by row
  skills        = dplyr::tibble(),
  text_blocks   = dplyr::tibble(),
  contact_info  = dplyr::tibble(),
  #' @field position_entry_template `glue` template for building position entries
  position_entry_template = default_position_entry_template,
  #' @field pdf_mode Is the output being rendered into a pdf? Aka do links need to be stripped?
  pdf_mode = FALSE,
  #' @field html_location Where will the html version of your CV be hosted?
  html_location = "",
  #' @field pdf_location Where will the pdf version of your CV be hosted?
  pdf_location = "",
  #' @field links Internal array holding all the links that have been stripped in the order they were stripped.
  links = c(),

  #' @description
  #' Create a CV_Printer object.
  #' @inheritParams use_datadriven_cv
  #' @param data_location Path of the spreadsheets holding all your data. This can be
  #'   either a URL to a google sheet with multiple sheets containing the four
  #'   data types or a path to a folder containing four `.csv`s with the neccesary
  #'   data.
  #' @param pdf_location What location will the PDF of this CV be hosted at?
  #' @param html_location What location will the HTML version of this CV be hosted at?
  #' @param pdf_mode Is the output being rendered into a pdf? Aka do links need to be stripped?
  #' @param position_entry_template A `glue` template for building position entries.
  #' @param sheet_is_publicly_readable If you're using google sheets for data, is the sheet publicly available? (Makes authorization easier.)
  #' @return A new `CV_Printer` object.
  initialize = function(data_location,
                        pdf_mode = FALSE,
                        html_location,
                        pdf_location,
                        position_entry_template = default_position_entry_template,
                        sheet_is_publicly_readable = TRUE) {
    self$pdf_mode <- pdf_mode
    self$html_location <- html_location
    self$pdf_location <- pdf_location
    self$position_entry_template = position_entry_template

    is_google_sheets_location <- stringr::str_detect(data_location, "docs\\.google\\.com")
    if(is_google_sheets_location){

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

      self$position_data <- googlesheets4::read_sheet(data_location, sheet = "positions")
      self$skills        <- googlesheets4::read_sheet(data_location, sheet = "language_skills")
      self$text_blocks   <- googlesheets4::read_sheet(data_location, sheet = "text_blocks")
      self$contact_info  <- googlesheets4::read_sheet(data_location, sheet = "contact_info", skip = 1)
    } else {
      # Want to go oldschool with just a csv?
      self$position_data <- readr::read_csv(paste0(data_location, "positions.csv"))
      self$skills        <- readr::read_csv(paste0(data_location, "language_skills.csv"))
      self$text_blocks   <- readr::read_csv(paste0(data_location, "text_blocks.csv"))
      self$contact_info  <- readr::read_csv(paste0(data_location, "contact_info.csv"), skip = 1)
    }

  },
  set_pdf_mode = function(pdf_mode = TRUE){
    self$pdf_mode <- pdf_mode
    invisible(self)
  },
  sanitize_links = function(text){
    out_text <- text
    if(self$pdf_mode){
      link_titles <- stringr::str_extract_all(text, '(?<=\\[).+?(?=\\])')[[1]]
      link_destinations <- stringr::str_extract_all(text, '(?<=\\().+?(?=\\))')[[1]]
      n_links <- length(link_titles)
      if(n_links > 0){
        # add links to links array
        self$links <- c(self$links, link_destinations)

        out_text <- text %>%
          stringr::str_replace_all(purrr::set_names(paste0("<sup>", 1:n_links, "</sup>"),
                                                    paste0("\\(", link_destinations, "\\)"))) %>%
          stringr::str_replace_all(purrr::set_names(link_titles, paste0("\\[", link_titles, "\\]")))
      }
    }
    out_text
  },
  # Take entire positions dataframe and removes the links
  # in descending order so links for the same position are
  # right next to eachother in number.
  strip_links_from_cols = function(data, cols_to_strip){
    for(i in 1:nrow(data)){
      for(col in cols_to_strip){
        data[i, col] <- self$sanitize_links(data[i, col])
      }
    }
    data
  },
  # Take a position dataframe and the section id desired
  # and prints the section to markdown.
  print_section = function(section_id){
    self$position_data %>%
      # Google sheets loves to turn columns into list ones if there are different types
      dplyr::mutate_if(is.list, purrr::map_chr, as.character) %>%
      dplyr::filter(section == section_id) %>%
      dplyr::mutate(
        end = ifelse(is.na(end), "Current", end),
        end_num = as.integer(ifelse(date_is_current(end), future_year, end))
      ) %>%
      dplyr::arrange(desc(end_num)) %>%
      dplyr::mutate(id = dplyr::row_number()) %>%
      tidyr::pivot_longer(
        tidyr::starts_with('description'),
        names_to = 'description_num',
        values_to = 'description'
      ) %>%
      dplyr::filter(!is.na(description) | description_num == 'description_1') %>%
      dplyr::group_by(id) %>%
      dplyr::mutate(
        descriptions = list(description),
        no_descriptions = is.na(dplyr::first(description))
      ) %>%
      dplyr::ungroup() %>%
      dplyr::filter(description_num == 'description_1') %>%
      dplyr::mutate(
        timeline = ifelse(
          is.na(start) | start == end,
          end,
          glue::glue('{end} - {start}')
        ),
        description_bullets = ifelse(
          no_descriptions,
          ' ',
          purrr::map_chr(descriptions, ~paste('-', ., collapse = '\n'))
        )
      ) %>%
      self$strip_links_from_cols(c('title', 'description_bullets')) %>%
      dplyr::mutate_all(~ifelse(is.na(.), 'N/A', .)) %>%
      glue::glue_data(self$position_entry_template)
  },
  print_text_block = function(label){
    dplyr::filter(self$text_blocks, loc == label) %>%
      dplyr::pull(text) %>%
      self$sanitize_links() %>%
      cat()
  },
  # Construct a bar chart of skills
  print_skill_bars = function(out_of = 5){
    bar_color <- "#969696"
    bar_background <- "#d9d9d9"
    self$skills %>%
      dplyr::mutate(width_percent = round(100*level/out_of)) %>%
      glue::glue_data(
        "<div class = 'skill-bar'",
        "style = \"background:linear-gradient(to right,",
        "{bar_color} {width_percent}%,",
        "{bar_background} {width_percent}% 100%)\" >",
        "{skill}",
        "</div>"
      )
  },
  print_links = function() {
    n_links <- length(self$links)
    if (n_links > 0) {
      cat(link_header)

      purrr::walk2(self$links, 1:n_links, function(link, index) {
        print(glue('{index}. {link}'))
      })
    }
  },
  print_contact_info = function(){
    self$contact_info %>%
      glue::glue_data("- <i class='fa fa-{icon}'></i> {contact}")
  },
  print_link_to_other_format = function(){
    # When in export mode the little dots are unaligned, so fix that.
    if(self$pdf_mode){
      glue::glue("View this CV online with links at _{self$html_location}_")
    } else {
      glue::glue("[<i class='fas fa-download'></i> Download a PDF of this CV]({self$pdf_location})")
    }
  },
  set_style = function(){
    # When in export mode the little dots are unaligned, so fix that.
    if(self$pdf_mode) {
      cat(pdf_style)
    }
  }
))

