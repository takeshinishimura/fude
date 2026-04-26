#' Extract a subset of Fude Polygon data
#'
#' @description
#' `extract_fude()` extracts a subset of Fude Polygon data returned by
#' [read_fude()] by year, municipality, former municipality, and/or
#' agricultural community.
#'
#' @param data
#'   A Fude Polygon data object returned by [read_fude()]. `data` may be a single
#'   data frame or a list of data frames.
#' @param year
#'   A numeric vector of issue years to extract. If `NULL`, all years are kept.
#' @param city
#'   A character vector of municipality names or local government codes used to
#'   identify target municipalities. If `NULL`, all municipalities are kept.
#' @param kcity
#'   A character vector of regular expression patterns used to match former
#'   municipality names in Japanese.
#' @param rcom
#'   A character vector of regular expression patterns used to match agricultural
#'   community names in Japanese.
#'
#' @returns
#'   An [sf::sf()] object containing the extracted subset.
#'
#' @seealso [read_fude()]
#'
#' @export
extract_fude <- function(
  data,
  year = NULL,
  city = NULL,
  kcity = "",
  rcom = ""
) {
  validate_fude(data)

  target_key <- find_key(
    city = city,
    kcity = kcity,
    rcom = rcom
  )

  if (is.data.frame(data)) {
    x <- data
  } else if (is.list(data)) {
    x <- dplyr::bind_rows(data)
  } else {
    stop("`data` must be a data.frame or a list.")
  }

  if (!is.null(year) && "issue_year" %in% names(x)) {
    x <- x |>
      dplyr::filter(.data$issue_year %in% year)
  }

  if (length(target_key) == 0) {
    return(x[0, , drop = FALSE])
  }

  if ("key" %in% names(x)) {
    x <- x |>
      dplyr::filter(.data$key %in% target_key)
  } else if ("local_government_cd" %in% names(x)) {
    x <- x |>
      dplyr::filter(.data$local_government_cd %in% unique(modulus11(target_key)))
  }

  return(x)
}

find_key <- function(
  city = NULL,
  kcity = "",
  rcom = ""
) {
  strip_jp_suffix <- function(x) {
    sub("(\u5e02|\u533a|\u753a|\u6751)$", "", x)
  }

  strip_kana_suffix <- function(x) {
    sub("(\u3057|\u304f|\u3061\u3087\u3046|\u307e\u3061|\u305d\u3093|\u3080\u3089)$", "", x)
  }

  has_text <- function(x) {
    !is.null(x) && length(x) > 0 && any(nzchar(x))
  }

  city_vec <- if (has_text(city)) city[nzchar(city)] else character()
  kcity_vec <- if (has_text(kcity)) kcity[nzchar(kcity)] else character()
  rcom_vec <- if (has_text(rcom)) rcom[nzchar(rcom)] else character()

  city_code <- city_vec[grepl("^\\d+$", city_vec)]
  city_jp <- strip_jp_suffix(city_vec)
  city_kana <- strip_kana_suffix(city_vec)
  city_romaji <- remove_romaji_suffix(city_vec)

  x <- fude::rcom_year_id |>
    dplyr::filter(.data$rcom_year == 2020) |>
    dplyr::left_join(fude::rcom_id_table, by = "id") |>
    dplyr::filter(
      if (length(city_vec) == 0) {
        TRUE
      } else {
        (.data$local_government_cd %in% city_code) |
          (strip_jp_suffix(.data$city_name) %in% city_jp) |
          (strip_kana_suffix(.data$city_kana) %in% city_kana) |
          (remove_romaji_suffix(.data$city_romaji) %in% city_romaji)
      },
      if (length(kcity_vec) == 0) {
        TRUE
      } else {
        Reduce(
          `|`,
          lapply(kcity_vec, \(i) grepl(i, .data$kcity_name, perl = TRUE))
        )
      },
      if (length(rcom_vec) == 0) {
        TRUE
      } else {
        Reduce(
          `|`,
          lapply(rcom_vec, \(i) grepl(i, .data$rcom_name, perl = TRUE))
        )
      }
    ) |>
    dplyr::pull(.data$key)

  return(x)
}
