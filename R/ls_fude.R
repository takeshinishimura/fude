#' Itemize the structure of Fude Polygon data
#'
#' @description
#' `ls_fude()` lists the year and the local government names (or codes) in
#' order to understand what is included in the list returned by [read_fude()].
#' @param data
#'   List of [sf::sf()] objects.
#' @returns A data.frame.
#' @seealso [read_fude()].
#'
#' @export
ls_fude <- function(data) {

  validate_fude(data)
  data <- add_local_government_cd(data)

  if (is.data.frame(data)) {

    x <- process_ls_data(data)

  } else if (is.list(data)) {

    x <- lapply(names(data), function(i) process_ls_data(data[[i]], name = i)) |>
      dplyr::bind_rows()

  }

  return(x)
}

validate_fude <- function(data) {
  if (is.data.frame(data)) {
    if (!"polygon_uuid" %in% names(data)) {
      stop("The data frame must contain a 'polygon_uuid' column.")
    }
  } else if (is.list(data)) {
    if (!"polygon_uuid" %in% names(data[[1]])) {
      stop("The first data frame in the list must contain a 'polygon_uuid' column.")
    }
  } else {
    stop("Input must be a Fude Polygon data.")
  }
}

process_ls_data <- function(data, name = NA) {
  data |>
    sf::st_set_geometry(NULL) |>
    dplyr::mutate(names = name) |>
    dplyr::distinct(names, .data$issue_year, .data$local_government_cd) |>
    dplyr::mutate(
      PREF_NAME = fude::pref_code_table$pref_kanji[match(substr(.data$local_government_cd, 1, 2), fude::pref_code_table$pref_code)],
      CITY_NAME = get_lg_name(.data$local_government_cd, romaji = NULL),
      CITY_ROMAJI = get_lg_name(.data$local_government_cd, romaji = "title")
    )
}
