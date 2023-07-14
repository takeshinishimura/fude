#' Get agricultural community boundary data
#'
#' @description
#' `filter_fude()` uses the agricultural community boundary data to reduce the
#' Fude Polygon data to the community units.
#' @param data
#'   List of [sf::sf()] objects.
#' @param boundary
#'   List of one or more agricultural community boundary data provided by
#'   the MAFF.
#' @param city
#'   A local government name in Japanese to be extracted. In the case of
#'   overlapping local government names, the prefecture name must be included
#'   (e.g., Fuchu-shi).
#' @param community
#'   String by regular expression. One or more agricultural community name in
#'   Japanese to be extracted.
#' @param year
#'   Year in the column name of the `data`, if there is more than one
#'   applicable local government code.
#' @returns A list of [sf::sf()] objects.
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path)
#' b <- get_boundary(d)
#' db <- filter_fude(d, b, "\u677e\u5c71\u5e02", "\u57ce\u6771", year = 2022)
#' @importFrom magrittr %>%
#' @export
filter_fude <- function(data, boundary, city, community, year = NULL) {
  location_info <- find_pref_name(city)
  dantai_code <- find_dantai_code(location_info$pref, location_info$city)

  local_government_cd <- unlist(
    lapply(names(data), function(i) unique(data[[i]]$local_government_cd)))

  data_no <- which(local_government_cd %in% dantai_code)
  if (length(data_no) != 1) {
    if (is.null(year)) {
      stop("Specify the year since there are multiple applicable local government codes.")
    } else {
      data_no <- data_no[which(as.character(year) == sub("(_.*)", "", names(data)[data_no]))]
      if (length(data_no) == 0) {
        stop("Specify the correct year.")
      }
    }
  }
  x <- data[[data_no]]

  pref <- substr(dantai_code, start = 1, stop = 2)
  y <- boundary[[pref]] %>%
    dplyr::filter(CITY_NAME == location_info$city &
                  grepl(community, RCOM_NAME)) %>%
    dplyr::mutate(RCOM_NAME = factor(RCOM_NAME, levels = RCOM_NAME))

  z <- sf::st_intersection(x, y)

  return(list(fude = z, boundary = y))
}

find_pref_name <- function(city) {
  matching_idx <- sapply(pref_table$pref_name, function(x) grepl(paste0("^", x), city))

  if (sum(matching_idx)) {

    pref <- pref_table$pref_name[matching_idx]
    after_pref <- gsub(glue::glue("^{pref}|\\s|\u3000"), "", city)

  } else {

    pref <- NULL
    after_pref <- city

  }

  return(list(pref = pref, city = after_pref))
}

find_dantai_code <- function(pref, after_pref) {
  if (is.null(pref)) {

    matching_idx <- dplyr::filter(lg_code, city_kanji == after_pref)

    if (nrow(matching_idx) > 1) {

      stop("Include the prefecture name in the argument 'city'.")

    }

  } else {

    matching_idx <- dplyr::filter(lg_code, pref_kanji == pref & city_kanji == after_pref)

  }

  return(matching_idx$dantai_code)
}
