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

  if (is.list(data)) {
    if ("fude" %in% names(data)) {
      issue_year <- data$fude$issue_year
      boundary_edit_year <- data$fude$boundary_edit_year
    } else {
      if ("polygon_uuid" %in% names(data)) {
        issue_year <- data$issue_year
        boundary_edit_year <- data$boundary_edit_year
      } else {
        issue_year <- unlist(lapply(data, function(df) {
          if ("issue_year" %in% names(df)) {
            return(df$issue_year)
          } else {
            stop("The input data must be Fude Polygon data.")
          }
        }))
        boundary_edit_year <- unlist(lapply(data, function(df) {
          return(df$boundary_edit_year)
        }))
      }
    }
  } else {
    if (is.data.frame(data)) {
      if ("issue_year" %in% names(data)) {
        issue_year <- data$issue_year
        boundary_edit_year <- data$boundary_edit_year
      } else {
        stop("The input data must be Fude Polygon data.")
      }
    } else {
      stop("The input data must be Fude Polygon data.")
    }
  }

  x <- list(
    ja = sprintf(
      "\u8FB2\u6797\u6C34\u7523\u7701\u300C\u7B46\u30DD\u30EA\u30B4\u30F3\u30C7\u30FC\u30BF\uFF08%s\u5E74\u5EA6\u516C\u958B\uFF09%s\u300D\u3092\u52A0\u5DE5\u3057\u3066\u4F5C\u6210\u3002",
      paste(sort(unique(issue_year)), collapse = "\uFF0C"),
      if (!is.null(boundary_edit_year)) {
        sprintf("\u300D\u304A\u3088\u3073\u300C\u8FB2\u696D\u96C6\u843D\u5883\u754C\u30C7\u30FC\u30BF\uFF08%s\u5E74\u5EA6\uFF09",
                paste(sort(unique(issue_year)), collapse = "\uFF0C"))
      } else {
        ""
      }
    ),
    en = sprintf(
      "Created by processing the Ministry of Agriculture, Forestry and Fisheries, 'Fude Polygon Data (released in FY%s)'%s.",
      paste(sort(unique(issue_year)), collapse = ", "),
      if (!is.null(boundary_edit_year)) {
        sprintf(" and 'Agricultural Community Boundary Data (FY%s)'",
                paste(sort(unique(issue_year)), collapse = ", "))
      } else {
        ""
      }
    )
  )

  return(x)

}
