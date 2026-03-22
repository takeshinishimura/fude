#' Generate citation text for Fude Polygon data
#'
#' @description
#' `cite_fude()` generates citation text in Japanese and English from Fude
#' Polygon data and related boundary data.
#'
#' @param data
#'   A Fude Polygon data object, boundary data object, or a data frame/list
#'   containing `issue_year` and/or `boundary_data_year`.
#'
#' @returns
#'   A list with two elements: `ja` for Japanese citation text and `en` for
#'   English citation text.
#'
#' @export
cite_fude <- function(data) {
  issue_year <- NULL
  boundary_data_year <- NULL

  if (is.data.frame(data)) {
    if ("issue_year" %in% names(data)) {
      issue_year <- unique(stats::na.omit(data$issue_year))
    }
    if ("boundary_data_year" %in% names(data)) {
      boundary_data_year <- unique(stats::na.omit(data$boundary_data_year))
    }
  } else if (is.list(data)) {
    issue_year <- unique(
      stats::na.omit(
        unlist(
          lapply(
            data,
            \(x) {
              if (is.data.frame(x) && "issue_year" %in% names(x)) {
                x[["issue_year"]]
              } else {
                NULL
              }
            }
          ),
          use.names = FALSE
        )
      )
    )

    boundary_data_year <- unique(
      stats::na.omit(
        unlist(
          lapply(
            data,
            \(x) {
              if (is.data.frame(x) && "boundary_data_year" %in% names(x)) {
                x[["boundary_data_year"]]
              } else {
                NULL
              }
            }
          ),
          use.names = FALSE
        )
      )
    )

    if (length(issue_year) == 0) {
      issue_year <- NULL
    }
    if (length(boundary_data_year) == 0) {
      boundary_data_year <- NULL
    }
  } else {
    stop("The input data must be a data.frame or a list.")
  }

  if (is.null(issue_year) && is.null(boundary_data_year)) {
    stop("The input data must contain `issue_year` and/or `boundary_data_year`.")
  }

  parts_ja <- character()

  if (!is.null(issue_year)) {
    parts_ja <- c(
      parts_ja,
      paste0(
        "\u300C\u7B46\u30DD\u30EA\u30B4\u30F3\u30C7\u30FC\u30BF\uFF08",
        paste(sort(issue_year), collapse = '\uFF0C'),
        "\u5E74\u5EA6\u516C\u958B\uFF09\u300D"
      )
    )
  }

  if (!is.null(boundary_data_year)) {
    parts_ja <- c(
      parts_ja,
      paste0(
        "\u300C\u8FB2\u696D\u96C6\u843D\u5883\u754C\u30C7\u30FC\u30BF\uFF08",
        paste(sort(boundary_data_year), collapse = '\uFF0C'),
        "\u5E74\u5EA6\uFF09\u300D"
      )
    )
  }

  combined_parts_ja <- if (length(parts_ja) > 1) {
    paste(parts_ja, collapse = "\u304A\u3088\u3073")
  } else {
    parts_ja
  }

  parts_en <- character()

  if (!is.null(issue_year)) {
    parts_en <- c(
      parts_en,
      paste0(
        "\"Fude Polygon Data (released in FY ",
        paste(sort(issue_year), collapse = ", "),
        ")\""
      )
    )
  }

  if (!is.null(boundary_data_year)) {
    parts_en <- c(
      parts_en,
      paste0(
        "\"Agricultural Community Boundary Data (FY ",
        paste(sort(boundary_data_year), collapse = ", "),
        ")\""
      )
    )
  }

  combined_parts_en <- if (length(parts_en) > 1) {
    paste(parts_en, collapse = " and ")
  } else {
    parts_en
  }

  list(
    ja = paste0(
      "\u8FB2\u6797\u6C34\u7523\u7701",
      combined_parts_ja,
      "\u3092\u52A0\u5DE5\u3057\u3066\u4F5C\u6210\u3002"
    ),
    en = paste0(
      "Created by processing data from the Ministry of Agriculture, Forestry and Fisheries",
      if (length(combined_parts_en) > 0) paste0(", ", combined_parts_en) else "",
      "."
    )
  )
}
