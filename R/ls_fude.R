#' List the contents of Fude Polygon data
#'
#' @description
#' `ls_fude()` summarizes the contents of a Fude Polygon data object returned by
#' [read_fude()]. It reports the data name, issue year, local government code,
#' number of records, and corresponding prefecture and municipality names.
#'
#' @param data
#'   A Fude Polygon data object returned by [read_fude()].
#'
#' @returns
#'   A data frame with one row per combination of data name, issue year, and local
#'   government code.
#'
#' @seealso [read_fude()]
#'
#' @export
ls_fude <- function(data) {
  validate_fude(data)

  data <- add_local_government_cd(data)

  if (is.data.frame(data)) {
    x <- process_ls_fude(data)
  } else if (is.list(data)) {
    data_names <- names(data)

    if (is.null(data_names)) {
      data_names <- rep(NA_character_, length(data))
    }

    x <- lapply(
      seq_along(data),
      \(i) {
        process_ls_fude(data[[i]], name = data_names[[i]])
      }
    )

    x <- dplyr::bind_rows(x)
  } else {
    stop("`data` must be a data.frame or a list.")
  }

  x <- x |>
    dplyr::arrange(.data$name, .data$issue_year, .data$local_government_cd)

  return(x)
}

process_ls_fude <- function(
  data,
  name = NA_character_
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
      pref_name = fude::pref_code_table$pref_name[
        match(
          substr(.data$local_government_cd, 1, 2),
          fude::pref_code_table$pref
        )
      ],
      city_name = get_lg_name(.data$local_government_cd, romaji = NULL),
      city_romaji = get_lg_name(.data$local_government_cd, romaji = "title")
    )
}
