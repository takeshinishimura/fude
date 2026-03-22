#' Bind multiple Fude Polygon data objects
#'
#' @description
#' `bind_fude()` combines multiple Fude Polygon data objects by binding elements
#' with the same names across inputs. It can also be used on objects that have
#' already been combined by [combine_fude()].
#'
#' @param ...
#'   Two or more Fude Polygon data objects to combine. Named elements that appear
#'   in multiple inputs are row-bound into a single [sf::sf()] object.
#'
#' @returns
#'   A named list of [sf::sf()] objects.
#'
#' @seealso [combine_fude()]
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

  all_names <- unique(unlist(lapply(databases, names)))

  x <- lapply(all_names, function(nm) {
    relevant_dbs <- lapply(
      databases,
      \(d) {
        if (nm %in% names(d)) d[[nm]] else NULL
      }
    )

    relevant_dbs <- relevant_dbs[!vapply(relevant_dbs, is.null, logical(1))]
    if (length(relevant_dbs) == 0) return(NULL)

    tmp <- dplyr::bind_rows(relevant_dbs)
    if (nrow(tmp) == 0) return(NULL)

    order_column <- if ("key" %in% names(tmp)) {
      "key"
    } else if ("local_government_cd" %in% names(tmp)) {
      "local_government_cd"
    } else {
      NULL
    }

    tmp <- tmp |>
      dplyr::distinct()

    if (!is.null(order_column)) {
      tmp <- tmp[order(tmp[[order_column]], decreasing = TRUE), ]
    }

    if ("fill" %in% names(tmp)) {
      tmp <- tmp |>
        dplyr::slice_max(order_by = .data$fill, n = 1, with_ties = TRUE)
    }

    if (!inherits(tmp, "sf")) {
      tmp <- sf::st_as_sf(tmp)
    }

    tmp
  })

  names(x) <- all_names

  return(x)
}
