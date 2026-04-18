#' Read a shuraku excel file
#'
#' @description
#' `read_ikasudb()` reads a shuraku Excel file provided by MAFF and joins its
#' tabular contents to agricultural community boundary data.
#'
#' @param boundary
#'   Agricultural community boundary data, typically returned by [get_boundary()].
#'   This can be a single boundary object or a list of boundary objects.
#' @param path
#'   Path to an `.xlsx` file provided by MAFF or a `.csv` file
#' @param na
#'   Character vector of strings to interpret as missing values. Defaults to
#'   `c("-", "\u2026")`.
#' @param zero
#'   Logical. If `TRUE`, treat masked values (`"x"` and `"X"`) as zero before
#'   numeric conversion.
#'
#' @returns
#'   An [sf::sf()] object created by joining the Excel data to `boundary`.
#'
#' @seealso [read_fude()]
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
  common_cols <- tolower(common_cols_upper)

  path_ext <- tolower(tools::file_ext(path))

  new_df <- switch(
    path_ext,
    "xlsx" = readxl::read_excel(
      path,
      na = na
    ),
    "csv" = readr::read_csv(
      file = path,
      na = na,
      col_types = "ccccc"
    ),
    stop("`path` must have extension '.xlsx' or '.csv'.")
  ) |>
    dplyr::rename_with(tolower, dplyr::any_of(common_cols_upper)) |>
    dplyr::mutate(
      dplyr::across(
        .cols = dplyr::where(is.character) & !dplyr::any_of(common_cols),
        .fns = \(col) {
          col2 <- trimws(col)

          if (isTRUE(zero)) {
            col2[col2 %in% c("x", "X")] <- "0"
          }

          col_no_na <- col2[!is.na(col2)]

          if (length(col_no_na) > 0 && all(grepl("^\\d+(\\.\\d+)?$", col_no_na))) {
            as.numeric(col2)
          } else {
            col2
          }
        }
      )
    )

  boundary_df <- dplyr::bind_rows(boundary)

  join_keys <- "key"
  missing_boundary <- setdiff(join_keys, names(boundary_df))
  missing_new_df <- setdiff(join_keys, names(new_df))

  if (length(missing_boundary) > 0) {
    stop(
      "`boundary` is missing required columns: ",
      paste(missing_boundary, collapse = ", ")
    )
  }

  if (length(missing_new_df) > 0) {
    stop(
      "Input file is missing required columns: ",
      paste(missing_new_df, collapse = ", ")
    )
  }

  drop_cols <- intersect(
    common_cols[common_cols != "key"],
    names(new_df)
  )

  x <- boundary_df |>
    dplyr::left_join(
      dplyr::select(new_df, -dplyr::any_of(drop_cols)),
      by = join_keys
    )

  return(x)
}
