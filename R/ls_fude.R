#' Itemize the structure of Fude Polygon data
#'
#' @description
#' `ls_fude()` lists the year and the local government names (or codes) in
#' order to understand what is included in the list returned by [read_fude()].
#'
#' @param data
#'   Fude Polygon data as returned by [read_fude()].
#'
#' @returns
#'   A data frame.
#'
#' @seealso [read_fude()].
#'
#' @export
ls_fude <- function(data) {
  validate_fude(data)

  data <- add_local_government_cd(data)

  if (is.data.frame(data)) {
    x <- process_ls_fude(data)
  } else if (is.list(data)) {
    x <- lapply(
      names(data),
      \(d) {
        process_ls_fude(data[[d]], name = d)
      }
    ) |>
      dplyr::bind_rows()
  }

  x <- x |>
    dplyr::arrange(.data$name, .data$issue_year, .data$local_government_cd)

  return(x)
}

process_ls_fude <- function(
  data,
  name = NA
) {
  data |>
    sf::st_set_geometry(NULL) |>
    dplyr::mutate(name = name) |>
    dplyr::count(
      .data$name,
      .data$issue_year,
      .data$local_government_cd,
      name = "n"
    ) |>
    dplyr::mutate(
      pref_name = fude::pref_code_table$pref_kanji[match(
        substr(.data$local_government_cd, 1, 2),
        fude::pref_code_table$pref_code
      )],
      city_name = get_lg_name(.data$local_government_cd, romaji = NULL),
      city_romaji = get_lg_name(.data$local_government_cd, romaji = "title")
    )
}
