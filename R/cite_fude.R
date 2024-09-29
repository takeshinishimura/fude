#' Generate Citation Text for Fude Polygon Data
#'
#' @description
#' Generates citation text in Japanese and English for Fude Polygon Data.
#' @param data
#'   A list or data frame containing Fude Polygon data.
#' @return A list with two elements: `ja` for Japanese citation text and `en`
#'   for English citation text.
#'
#' @examples
#' data <- list(fude = data.frame(issue_year = c(2021, 2020), boundary_edit_year = c(2019, 2020)))
#' cite_fude(data)
#'
#' @export
cite_fude <- function(data) {

  if (is.data.frame(data)) {

    issue_year <- unique(data$issue_year)
    boundary_edit_year <- unique(data$boundary_edit_year)

  } else if (is.list(data)) {

    issue_year <- unique(unlist(sapply(data, `[[`, "issue_year")))
    boundary_edit_year <- unique(unlist(sapply(data, `[[`, "boundary_edit_year")))

  }

  if (is.null(issue_year) & is.null(boundary_edit_year)) {
    stop("The input data must be Fude Polygon data.")
  }

  parts_ja <- c()
  if (!is.null(issue_year)) {
    parts_ja <- c(parts_ja, glue::glue("\u300C\u7B46\u30DD\u30EA\u30B4\u30F3\u30C7\u30FC\u30BF\uFF08{paste(sort(issue_year), collapse = '\uFF0C')}\u5E74\u5EA6\u516C\u958B\uFF09\u300D"))
  }
  if (!is.null(boundary_edit_year)) {
    parts_ja <- c(parts_ja, glue::glue("\u300C\u8FB2\u696D\u96C6\u843D\u5883\u754C\u30C7\u30FC\u30BF\uFF08{paste(sort(boundary_edit_year), collapse = '\uFF0C')}\u5E74\u5EA6\uFF09\u300D"))
  }
  combined_parts_ja <- if (length(parts_ja) > 1) {
    paste(parts_ja, collapse = "\u304A\u3088\u3073")
  } else if (length(parts_ja) == 1) {
    parts_ja
  } else {
    ""
  }

  parts_en <- c()
  if (!is.null(issue_year)) {
    parts_en <- c(parts_en, glue::glue("'Fude Polygon Data (released in FY{paste(sort(issue_year), collapse = ', ')})'"))
  }
  if (!is.null(boundary_edit_year)) {
    parts_en <- c(parts_en, glue::glue("'Agricultural Community Boundary Data (FY{paste(sort(boundary_edit_year), collapse = ', ')})'"))
  }
  combined_parts_en <- if (length(parts_en) > 1) {
    paste(parts_en, collapse = " and ")
  } else if (length(parts_en) == 1) {
    parts_en
  } else {
    ""
  }

  x <- list(
    ja = glue::glue("\u8FB2\u6797\u6C34\u7523\u7701{combined_parts_ja}\u3092\u52A0\u5DE5\u3057\u3066\u4F5C\u6210\u3002"),
    en = glue::glue("Created by processing the Ministry of Agriculture, Forestry and Fisheries{if (combined_parts_en != '') ', ' else ''}{combined_parts_en}.")
  )

  return(x)

}
