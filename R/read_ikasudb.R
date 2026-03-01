#' Read shuraku data
#'
#' @description
#' `read_ikasudb()` reads shuraku Excel files provided by MAFF.
#'
#' @param boundary
#'   Agricultural community boundary data as returned by [get_boundary()].
#' @param path
#'   Path to an `.xlsx` file.
#' @param na
#'   Character vector of strings to interpret as missing values. Defaults to
#'   `c("-", "\u2026")`.
#' @param zero
#'   Logical. If `TRUE`, treat masked values (`"x"` and `"X"`) as zero.
#'
#' @returns
#'   An [sf::sf()] object.
#'
#' @export
read_ikasudb <- function(
  boundary,
  path,
  na = c("-", "\u2026"),
  zero = TRUE
) {
  common_cols_upper <- c(
    "KEY",
    "PREF", "CITY", "KCITY", "RCOM",
    "PREF_NAME", "CITY_NAME", "KCITY_NAME", "RCOM_NAME"
  )
  common_cols_lower <- tolower(common_cols_upper)

  x <- readxl::read_excel(
    path,
    na = na
  ) |>
    dplyr::rename_with(tolower, dplyr::any_of(common_cols_upper)) |>
    dplyr::mutate(dplyr::across(
      .cols = dplyr::where(is.character) & !dplyr::any_of(common_cols_lower),
      .fns = \(col) {
        col2 <- trimws(col)

        if (isTRUE(zero)) {
          col2[col2 %in% c("x", "X")] <- "0"
        }

        col_no_na <- col2[!is.na(col2)]
        if (length(col_no_na) > 0 && all(grepl("^\\d+(\\.\\d+)?$", col_no_na))) {
          as.numeric(col2)
        } else {
          col
        }
      }
    ))

  b <- dplyr::bind_rows(boundary)
  nb <- names(b)

  by <- if ("rcom" %in% nb) {
    c("key", "pref", "city", "kcity", "rcom")
  } else if ("kcity" %in% nb) {
    c("key", "pref", "city", "kcity")
  } else {
    c("key", "pref", "city")
  }

  x <- b |>
    dplyr::left_join(
      dplyr::select(
        x,
        -c(.data$pref_name, .data$city_name, .data$kcity_name, .data$rcom_name)
      ),
      by = by
    )

  return(x)
}
