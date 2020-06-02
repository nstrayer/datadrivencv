#' Build interactive network logo
#'
#' Constructs a network based on your position data to be used as a logo.
#' Interactive in HTML version and static in the PDF version. Notes are entries,
#' colored by section and connected if they occurred in the same year
#'
#' @param position_data position data from your `CV_Printer` class.
#'
#' @return Interactive force-directed layout network of your CV data
#' @export
build_network_logo <- function(position_data){

  positions <- position_data %>%
    dplyr::mutate(
      id = dplyr::row_number(),
      title = stringr::str_remove_all(title, '(\\(.+?\\))|(\\[)|(\\])'),
      section = stringr::str_replace_all(section, "_", " ") %>% stringr::str_to_title()
    )

  combination_indices <- function(n){
    rep_counts <- (n:1) - 1
    dplyr::tibble(
      a = rep(1:n, times = rep_counts),
      b = purrr::flatten_int( purrr::map(rep_counts, ~{tail(1:n, .x)}) )
    )
  }
  current_year <- lubridate::year(lubridate::ymd(Sys.Date()))
  edges <- positions %>%
    dplyr::select(id, start_year, end_year) %>%
    dplyr::mutate(
      end_year = ifelse(end_year > current_year, current_year, end_year),
      start_year = ifelse(start_year > current_year, current_year, start_year)
    ) %>%
    purrr::pmap_dfr(function(id, start_year, end_year){
      dplyr::tibble(
        year = start_year:end_year,
        id = id
      )
    }) %>%
    dplyr::group_by(year) %>%
    tidyr::nest() %>%
    dplyr::rename(ids_for_year = data) %>%
    purrr::pmap_dfr(function(year, ids_for_year){
      combination_indices(nrow(ids_for_year)) %>%
        dplyr::transmute(
          year = year,
          source = ids_for_year$id[a],
          target = ids_for_year$id[b]
        )
    })

  network_data <- list(nodes = dplyr::select(positions, -in_resume,-timeline),
                       edges = edges) %>%
    jsonlite::toJSON()

  viz_script <- readr::read_file(system.file("js/cv_network.js", package = "datadrivencv"))

  glue::glue(
    "<script id = \"data_for_network\" type = \"application/json\">",
    "{network_data}",
    "</script>",
    "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/d3/5.16.0/d3.min.js\"></script>",
    "<svg style = \"width: 100%; height:320px; margin-top: -125px;\" id = \"cv_network_viz\"></svg>",
    "<script>",
    "{viz_script}",
    "</script>"
  )

}
