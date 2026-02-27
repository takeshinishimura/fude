#' Extract specified Fude Polygon data
#'
#' @description
#' `extract_fude()` extracts the specified data from the list returned by
#' [read_fude()].
#'
#' @param data
#'   List of MAFF Fude Polygon data.
#' @param year
#'   One or more years to extract.
#' @param city
#'   A local government name or code (6-digit) to extract.
#' @param kcity
#'   A regular expression string. One or more former city names (in Japanese)
#'   to extract.
#' @param rcom
#'   A regular expression string. One or more agricultural community names (in
#'   Japanese) to extract.
#'
#' @returns A list of [sf::sf()] object(s).
#'
#' @seealso [read_fude()].
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

  # if (is.null(year) & is.null(city)) {
  #   stop("Specify either `year` or `city`.")
  # }

  target_key <- find_key(
    city = city,
    kcity = kcity,
    rcom = rcom
  )

  x <- data |>
    dplyr::bind_rows()

  if (!is.null(year)) {
    x <- x |>
      dplyr::filter(.data$issue_year %in% year)
  }

  if ("key" %in% names(x)) {
    x <- x |>
      dplyr::filter(
        .data$key %in% target_key
      )
  } else if ("local_government_cd" %in% names(x)) {
    x <- x |>
      dplyr::filter(
        .data$local_government_cd %in% unique(modulus11(target_key))
      )
  }

  return(x)
}

find_key <- function(
  city = city,
  kcity = kcity,
  rcom = rcom
) {
  strip_jp_suffix <- function(x) {
    sub("(\u5e02|\u533a|\u753a|\u6751)$", "", x)
  }

  strip_kana_suffix <- function(x) {
    sub(
      "(\u3057|\u304f|\u3061\u3087\u3046|\u307e\u3061|\u305d\u3093|\u3080\u3089)$",
      "",
      x
    )
  }

  strip_romaji_suffix <- function(x) {
    tolower(gsub(
      "-SHI|-KU|-CHO|-MACHI|-SON|-MURA",
      "",
      x,
      ignore.case = TRUE
    ))
  }

  has_city <- !(is.null(city) || length(city) == 0 || all(!nzchar(city)))

  city_vec <- if (has_city) city[nzchar(city)] else character()

  city_code <- city_vec[grepl("^\\d+$", city_vec)]
  city_jp <- strip_jp_suffix(city_vec)
  city_kana <- strip_kana_suffix(city_vec)
  city_romaji <- strip_romaji_suffix(city_vec)

  x <- fude::rcom_code_table |>
    dplyr::filter(
      if (!has_city) {
        TRUE
      } else {
        ((.data$local_government_cd %in% city_code) |
          (strip_jp_suffix(.data$city_name) %in% city_jp) |
          (strip_kana_suffix(.data$city_kana) %in% city_kana) |
          (strip_romaji_suffix(.data$city_romaji) %in% city_romaji))
      },
      if (is.null(kcity) || length(kcity) == 0 || !nzchar(kcity)) {
        TRUE
      } else {
        grepl(kcity, .data$kcity_name, perl = TRUE)
      },
      if (is.null(rcom) || length(rcom) == 0 || !nzchar(rcom)) {
        TRUE
      } else {
        grepl(rcom, .data$rcom_name, perl = TRUE)
      }
    ) |>
    dplyr::pull(.data$key)

  return(x)
}
