#' Combine the Fude Polygon data with the agricultural community boundary data
#'
#' @description
#' `combine_fude()` uses the agricultural community boundary data to reduce the
#' Fude Polygon data to the community units.
#' @param data
#'   List of [sf::sf()] objects.
#' @param boundary
#'   List of one or more agricultural community boundary data provided by
#'   the MAFF.
#' @param city
#'   A local government name in Japanese to be extracted. In the case of
#'   overlapping local government names, the prefecture name must be included
#'   (e.g., Fuchu-shi). Alternatively, it could be a local government code.
#' @param community
#'   String by regular expression. One or more agricultural community name in
#'   Japanese to be extracted.
#' @param year
#'   Year in the column name of the `data`, if there is more than one
#'   applicable local government code.
#' @returns A list of [sf::sf()] objects.
#' @examplesIf interactive()
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path)
#' b <- get_boundary(d)
#' db <- combine_fude(d, b, "\u677e\u5c71\u5e02", "\u57ce\u6771", year = 2022)
#' @importFrom magrittr %>%
#' @export
combine_fude <- function(data, boundary, city, community, year = NULL) {
  location_info <- find_pref_name(city)
  lg_code <- find_lg_code(location_info$pref, location_info$city)

  local_government_cd <- unlist(
    lapply(names(data), function(i) unique(data[[i]]$local_government_cd)))

  data_no <- which(local_government_cd %in% lg_code)
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

  pref <- substr(lg_code, start = 1, stop = 2)
  community_city <- dplyr::if_else(grepl("\u533a$", location_info$city),
                                   sub(".*\u5e02", "", location_info$city),
                                   location_info$city)

  y <- boundary[[pref]] %>%
    dplyr::mutate(RCOM_NAME = dplyr::if_else(is.na(.data$RCOM_NAME), "", .data$RCOM_NAME)) %>%
    dplyr::filter(.data$CITY_NAME == community_city &
                  grepl(community, .data$RCOM_NAME)) %>%
    dplyr::mutate(RCOM_NAME = factor(.data$RCOM_NAME, levels = unique(.data$RCOM_NAME)))

  z <- sf::st_intersection(x, y)

  return(list(fude = z, boundary = y))
}

find_pref_name <- function(city) {
  if (grepl("^\\d{6}$", city)) {

    matching_idx <- which(fude::lg_code_table$lg_code == city)
    pref_kanji <- fude::lg_code_table$pref_kanji[matching_idx]
    city_kanji <- fude::lg_code_table$city_kanji[matching_idx]

  } else {

    matching_idx <- sapply(fude::pref_table$pref_kanji, function(x) grepl(paste0("^", x), city))

    if (sum(matching_idx) == 1) {

      pref_kanji <- fude::pref_table$pref_kanji[matching_idx]
      city_kanji <- gsub(glue::glue("^{pref_kanji}|\\s|\u3000"), "", city)

    } else {

      pref_kanji <- NULL
      city_kanji <- city

    }

  }

  return(list(pref = pref_kanji, city = city_kanji))
}

find_lg_code <- function(pref, city) {
  if (is.null(pref)) {

    matching_idx <- dplyr::filter(fude::lg_code_table, .data$city_kanji == city)

    if (nrow(matching_idx) > 1) {

      stop("Include the prefecture name in the argument 'city'.")

    }

  } else {

    matching_idx <- dplyr::filter(fude::lg_code_table, .data$pref_kanji == pref & .data$city_kanji == city)

  }

  return(matching_idx$lg_code)
}
