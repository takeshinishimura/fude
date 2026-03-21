#' Bind multiple Fude Polygon data
#'
#' @description
#' `bind_fude()` binds a list of polygon data. It also binds a list of data
#' combined by [combine_fude()].
#'
#' @param ...
#'   Database lists to be combined. They should all have the same named
#'   elements.
#'
#' @returns
#'   A list of [sf::sf()] object(s).
#'
#' @seealso [read_fude()], [combine_fude()].
#'
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d1 <- read_fude(path, quiet = TRUE)
#' d2 <- read_fude(path, quiet = TRUE)
#' bind_fude(d1, d2)
#'
#' @export
bind_fude <- function(...) {
  databases <- list(...)

  all_names <- unique(
    unlist(
      lapply(databases, names)
    )
  )

  x <- lapply(
    all_names,
    \(x) {
      relevant_dbs <- lapply(
        databases,
        \(d) {
          if (x %in% names(d)) {
            return(d[[x]])
          } else {
            return(NULL)
          }
        }
      )

      tmp <- dplyr::bind_rows(
        relevant_dbs[!sapply(relevant_dbs, is.null)]
      )

      if (is.null(tmp) || nrow(tmp) == 0) {
        return(NULL)
      }

      order_column <- if ("local_government_cd" %in% names(tmp)) {
        "local_government_cd"
      } else {
        "pref_code"
      }

      if ("fill" %in% names(tmp)) {
        tmp <- tmp |>
          dplyr::distinct() |>
          dplyr::arrange(dplyr::desc(.data[[order_column]])) |>
          dplyr::slice_max(order_by = .data$fill, n = 1, with_ties = TRUE)
      } else {
        tmp <- tmp |>
          dplyr::distinct() |>
          dplyr::arrange(dplyr::desc(.data[[order_column]]))
      }

      sf::st_as_sf(tmp)
    }
  )

  names(x) <- all_names
  return(x)
}
