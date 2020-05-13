
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

# Cleans up positions data to easily printable format
process_position_data <- function(position_data) {
  position_data %>%
    tidyr::unite(
      tidyr::starts_with('description'),
      col = "description_bullets",
      sep = "\n- ",
      na.rm = TRUE
    ) %>%
    dplyr::mutate(
      description_bullets = paste0("- ", description_bullets),
      end = ifelse(is.na(end), "Current", end),
      timeline = ifelse(is.na(start) | start == end,
                        end,
                        glue::glue('{end} - {start}'))
    ) %>%
    dplyr::arrange(desc(ifelse(date_is_current(end), future_year, end))) %>%
    dplyr::mutate_all(~ ifelse(is.na(.), 'N/A', .))
}

#' R6 Class to print components of CV from data
#'
#' This class is initiated at the head of your CV or Resume Rmarkdown file and
#' then through various `print_*` methods, builds the various components.
#'
#'
#' @export
CV_Printer <- R6::R6Class("CV_Printer", public = list(
  #' @field position_data data frame of positions by row with columns:
  #' * `section` What type of position entry,
  #' * `title` Title of entry,
  #' * `loc` Where the position took place,
  #' * `institution` Institution the position was associated with,
  #' * `start` Start year of position
  #' * `end` End year of position,
  #' * `in_resume` Logical to filter what entries should be included in a resume (Not used for CV mode),
  #' * `description_{1,2,...}` Free form text fields to be added as description bullets.	description_2	description_3
  position_data = dplyr::tibble(),

  #' @field skills data frame with two columns:
  #'  * `skill` ID of skill
  #'  * `level` Relative numeric level for skill
  skills = dplyr::tibble(),

  #' @field text_blocks data frame with two columns:
  #' * `loc` Where this text lock is going in CV
  #' * `text` Actual text to be placed.
  text_blocks   = dplyr::tibble(),

  #' @field contact_info data frame with three columns:
  #' * `loc` What the contact point is for (e.g. email)
  #' * `icon` Font-awesome 4 icon id for this contact point (e.g. "envelope")
  #' * `contact` Actual contact info such as `nick@test.com`.
  contact_info  = dplyr::tibble(),

  #' @field pdf_mode Is the output being rendered into a pdf? Aka do links need to be stripped?
  pdf_mode = FALSE,

  #' @field html_location Where will the html version of your CV be hosted?
  html_location = "",

  #' @field pdf_location Where will the pdf version of your CV be hosted?
  pdf_location = "",


  #' @description Create a CV_Printer object.
  #'
  #' @param data_location Path of the spreadsheets holding all your data. This can be
  #'   either a URL to a google sheet with multiple sheets containing the four
  #'   data types or a path to a folder containing four `.csv`s with the neccesary
  #'   data.
  #' @param pdf_location What location will the PDF of this CV be hosted at?
  #' @param html_location What location will the HTML version of this CV be hosted at?
  #' @param source_location Where is the code to build your CV hosted?
  #' @param pdf_mode Is the output being rendered into a pdf? Aka do links need
  #'   to be stripped?
  #' @param position_entry_template A `glue` template for building position
  #'   entries.
  #' @param sheet_is_publicly_readable If you're using google sheets for data,
  #'   is the sheet publicly available? (Makes authorization easier.)
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
    private$position_entry_template = position_entry_template

    is_google_sheets_location <- stringr::str_detect(data_location, "docs\\.google\\.com")
    if(is_google_sheets_location){
      private$load_data_from_googlesheets(data_location, sheet_is_publicly_readable)
    } else {
      # Want to go oldschool with just a csv?
      private$load_data_from_csvs(data_location)
    }

    # Clean up positions dataframe to format we need it for printing
    self$position_data <- process_position_data(self$position_data)
  },

  #' @description Turn on pdf mode for class. Useful for when the class is cached to avoid re-downloading data.
  #'
  #' @param pdf_mode Are we turning PDF mode on?
  set_pdf_mode = function(pdf_mode = TRUE){
    self$pdf_mode <- pdf_mode
    invisible(self)
  },

  #' @description Take a position data frame and the section id desired and prints the section to markdown.
  #' @param section_id ID of the positions section to be printed as encoded by the `section` column of the `positions` table
  print_section = function(section_id){
    dplyr::filter(self$position_data, section == section_id) %>%
      private$strip_links_from_cols(c('title', 'description_bullets')) %>%
      glue::glue_data(private$position_entry_template)
  },

  #' @description Prints out text block identified by a given label.
  #' @param label ID of the text block to print as encoded in `label` column of `text_blocks` table.
  print_text_block = function(label){
    dplyr::filter(self$text_blocks, loc == label) %>%
      dplyr::pull(text) %>%
      private$sanitize_links() %>%
      cat()
  },

  #' @description Construct a bar chart of skills
  #' @param out_of The relative maximum for skills. Used to set what a fully filled in skill bar is.
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

  #' @description List of all links in document labeled by their superscript integer.
  print_links = function() {
    n_links <- length(private$links)
    if (n_links > 0) {
      cat(link_header)

      purrr::walk2(private$links, 1:n_links, function(link, index) {
        print(glue::glue('{index}. {link}'))
      })
    }
  },

  #' @description Contact information section with icons
  print_contact_info = function(){
    glue::glue_data(
      self$contact_info,
      "- <i class='fa fa-{icon}'></i> {contact}"
    )
  },

  #' @description Small addendum that links to pdf version of CV if currently HTML and HTML if currently PDF.
  print_link_to_other_format = function(){
    # When in export mode the little dots are unaligned, so fix that.
    if(self$pdf_mode){
      glue::glue("View this CV online with links at _{self$html_location}_")
    } else {
      glue::glue("[<i class='fas fa-download'></i> Download a PDF of this CV]({self$pdf_location})")
    }
  },

  #' @description Appends some styles specific to PDF output.
  set_style = function(){
    # When in export mode the little dots are unaligned, so fix that.
    if(self$pdf_mode) {
      cat(pdf_style)
    }
  }
),

private = list(
  #' `glue` template for building position entries
  position_entry_template = default_position_entry_template,

  #' Internal array holding all the links that have been stripped in the order they were stripped.
  links = c(),

  # Remove links from a text block and add to internal list
  sanitize_links = function(text){
    if(self$pdf_mode){
      link_titles <- stringr::str_extract_all(text, '(?<=\\[).+?(?=\\])')[[1]]
      link_destinations <- stringr::str_extract_all(text, '(?<=\\().+?(?=\\))')[[1]]

      n_links <- length(private$links)
      n_new_links <- length(link_titles)

      if(n_new_links > 0){
        # add links to links array
        private$links <- c(private$links, link_destinations)

        # Build map of link destination to superscript
        link_superscript_mappings <- purrr::set_names(
          paste0("<sup>", (1:n_new_links) + n_links, "</sup>"),
          paste0("(", link_destinations, ")")
        )

        # Replace the link destination and remove square brackets for title
        text <- text %>%
          stringr::str_replace_all(stringr::fixed(link_superscript_mappings)) %>%
          stringr::str_replace_all('\\[(.+?)\\]', "\\1")
      }
    }
    text
  },

  # Take entire positions data frame and removes the links in descending order
  # so links for the same position are right next to each other in number.
  strip_links_from_cols = function(data, cols_to_strip){
    for(i in 1:nrow(data)){
      for(col in cols_to_strip){
        data[i, col] <- private$sanitize_links(data[i, col])
      }
    }
    data
  },

  load_data_from_googlesheets = function(data_location, sheet_is_publicly_readable){

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

    self$position_data <- googlesheets4::read_sheet(data_location, sheet = "positions") %>%
      # Google sheets loves to turn columns into list ones if there are different types
      dplyr::mutate_if(is.list, purrr::map_chr, as.character)

    self$skills        <- googlesheets4::read_sheet(data_location, sheet = "language_skills")
    self$text_blocks   <- googlesheets4::read_sheet(data_location, sheet = "text_blocks")
    self$contact_info  <- googlesheets4::read_sheet(data_location, sheet = "contact_info", skip = 1)
  },

  load_data_from_csvs = function(data_location){
    self$position_data <- readr::read_csv(paste0(data_location, "positions.csv"))
    self$skills        <- readr::read_csv(paste0(data_location, "language_skills.csv"))
    self$text_blocks   <- readr::read_csv(paste0(data_location, "text_blocks.csv"))
    self$contact_info  <- readr::read_csv(paste0(data_location, "contact_info.csv"), skip = 1)
  }
))

