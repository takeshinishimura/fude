#' Bind multiple Fude Polygon data
#'
#' @description
#' `bind_fude()` binds a list of polygon data. It also binds a list of data
#' combined by [combine_fude()].
#' @param ...
#'   Database lists to be combined. They should all have the same named
#'   elements.
#' @returns A list of [sf::sf()] object(s).
#' @seealso [read_fude()], [combine_fude()].
#'
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d1 <- read_fude(path, stringsAsFactors = FALSE, quiet = TRUE)
#' d2 <- read_fude(path, stringsAsFactors = FALSE, quiet = TRUE)
#' bind_fude(d1, d2)
#'
#' @export
bind_fude <- function(...) {
  databases <- list(...)

  all_names <- purrr::reduce(databases, function(db1, db2) {
    union(names(db1), names(db2))
  })

  x <- purrr::map(all_names, function(current_name) {
    relevant_dbs <- purrr::map(databases, function(db) {
      if (current_name %in% names(db)) {
        return(db[[current_name]])
      } else {
        return(NULL)
      }
    })

    tmp <- do.call(dplyr::bind_rows, purrr::discard(relevant_dbs, is.null))

    if(is.null(tmp)) {
      return(NULL)
    }

    order_column <- dplyr::case_when(
      "local_government_cd" %in% names(tmp) ~ "local_government_cd",
      TRUE ~ "pref_code"
    )

    if ("fill" %in% names(tmp)) {
      tmp %>%
        dplyr::distinct() %>%
        dplyr::arrange(dplyr::desc(!!rlang::sym(order_column))) %>%
        dplyr::group_by(dplyr::across(-c(.data$fill))) %>%
        dplyr::slice_max(.data$fill, n = 1, with_ties = TRUE) %>%
        dplyr::ungroup() %>%
        as.data.frame() %>%
        sf::st_sf()
    } else {
      tmp %>%
        dplyr::distinct() %>%
        dplyr::arrange(dplyr::desc(!!rlang::sym(order_column))) %>%
        as.data.frame() %>%
        sf::st_sf()
    }

  })

  names(x) <- all_names

  return(x)
}
