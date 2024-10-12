#' Extract specified agricultural community boundary data
#'
#' @description
#' `extract_boundary()` extracts the specified data from the list returned by
#' [get_boundary()].
#' @param boundary
#'   List of one or more agricultural community boundary data provided by
#'   the MAFF.
#' @param city
#'   A local government name in Japanese to be extracted. In the case of
#'   overlapping local government names, this must contain the prefecture name
#'   in Japanese and the prefecture code in romaji (e.g., "Fuchu-shi, 13",
#'   "fuchu 13",  "34 fuchu-shi",  "34, FUCHU-CHO"). Alternatively, it could be
#'   a 6-digit local government code.
#' @param old_village
#'   String by regular expression. One or more old village name in Japanese to
#'   be extracted.
#' @param community
#'   String by regular expression. One or more agricultural community name in
#'   Japanese to be extracted.
#' @param all
#'   logical.
#' @returns A list of [sf::sf()] object(s).
#' @seealso [read_fude()].
#'
#' @export
extract_boundary <- function(boundary,
                             city,
                             old_village = "",
                             community = "",
                             all = FALSE) {

  location_info <- find_pref_name(city)
  lg_code <- find_lg_code(location_info$pref, location_info$city)
  pref_code <- fude_to_pref_code(lg_code)

  community_city <- fude::lg_code_table$city_kanji[fude::lg_code_table$lg_code == lg_code]
  community_city <- dplyr::if_else(grepl("\u533a$", community_city), sub(".*\u5e02", "", community_city), community_city)

  pref_boundary <- boundary[[pref_code]] %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      local_government_cd = sapply(
        paste0("^", .data$PREF, .data$CITY, "\\d$"),
        function(pattern) {
          matched_codes <- grep(pattern, fude::lg_code_table$lg_code, value = TRUE)
          if (length(matched_codes) > 0) {
            paste(matched_codes, collapse = ", ")
          } else {
            NA_character_
          }
        }
      )
    ) %>%
    sf::st_make_valid()

  extracted_boundary <- pref_boundary %>%
    dplyr::mutate(
      KCITY_NAME = dplyr::if_else(is.na(.data$KCITY_NAME), "", .data$KCITY_NAME),
      RCOM_NAME = dplyr::if_else(is.na(.data$RCOM_NAME), "", .data$RCOM_NAME)
    ) %>%
    dplyr::filter(.data$CITY_NAME == community_city &
                  grepl(old_village, .data$KCITY_NAME, perl = TRUE) &
                  grepl(community, .data$RCOM_NAME, perl = TRUE)) %>%
    dplyr::mutate(
      KCITY_NAME = forcats::fct_inorder(.data$KCITY_NAME),
      RCOM_NAME = forcats::fct_inorder(.data$RCOM_NAME),
      RCOM_KANA = forcats::fct_inorder(.data$RCOM_KANA),
      RCOM_ROMAJI = forcats::fct_inorder(.data$RCOM_ROMAJI)
    ) %>%
    as.data.frame() %>%
    sf::st_sf() %>%
    add_xy()

  extracted_boundary_union <- extracted_boundary %>%
    sf::st_union() %>%
    sf::st_sf() %>%
    dplyr::mutate(
      local_government_cd = paste0(unique(extracted_boundary$local_government_cd), collapse = "/")
    ) %>%
    as.data.frame() %>%
    sf::st_sf() %>%
    add_xy()

  geometries <- pref_boundary %>%
    sf::st_union() %>%
    sf::st_geometry()
  pref_map <- sf::st_sf(pref_code = fude_to_pref_code(pref_boundary),
                        geometry = geometries) %>%
    sf::st_set_crs(4326) %>%
    dplyr::left_join(fude::pref_table, by = "pref_code") %>%
    add_xy()

  unique_local_government_cd <- unique(pref_boundary$local_government_cd)
  geometries <- purrr::map(unique_local_government_cd,
                           function(cd) {
                             pref_boundary %>%
                               dplyr::filter(grepl(cd, .data$local_government_cd)) %>%
                               sf::st_union() %>%
                               sf::st_geometry() %>%
                               .[[1]]
                           }) %>% do.call(sf::st_sfc, .)
  lg_df <- sf::st_sf(local_government_cd = unique_local_government_cd,
                     geometry = geometries) %>%
    sf::st_set_crs(4326)
  lg_ls <- fude::lg_code_table %>%
    dplyr::filter(.data$lg_code %in% unique_local_government_cd) %>%
    dplyr::select(local_government_cd = .data$lg_code, .data$pref_kanji, .data$city_kanji, .data$romaji)
  lg_all_map <- dplyr::inner_join(lg_df, lg_ls, by = "local_government_cd")

  lg_all_map <- lg_all_map %>%
    dplyr::mutate(
      fill = factor(dplyr::if_else(.data$city_kanji == location_info$city, 1, 0))
    ) %>%
    add_xy()

  pref_boundary_KCITY_code <- pref_boundary %>%
    dplyr::mutate(KCITY_code = paste(.data$local_government_cd,
                                     .data$PREF,
                                     .data$CITY,
                                     .data$KCITY,
                                     .data$PREF_NAME,
                                     .data$CITY_NAME,
                                     .data$KCITY_NAME, sep = "_"))
  unique_KCITY <- unique(pref_boundary_KCITY_code$KCITY_code)
  geometries <- purrr::map(unique_KCITY,
                           function (cd) {
                             pref_boundary_KCITY_code %>%
                               dplyr::filter(grepl(cd, .data$KCITY_code)) %>%
                               sf::st_union() %>%
                               sf::st_geometry() %>%
                               .[[1]]
                           }) %>% do.call(sf::st_sfc, .)
  ov_df <- sf::st_sf(KCITY_code = unique_KCITY, geometry = geometries) %>%
    tidyr::separate(.data$KCITY_code, into = c("local_government_cd",
                                               "PREF",
                                               "CITY",
                                               "KCITY",
                                               "PREF_NAME",
                                               "CITY_NAME",
                                               "KCITY_NAME"), sep = "_")
  ov_df$KCITY_NAME[ov_df$KCITY_NAME == "NA"] <- NA

  ov_all_map <- ov_df %>%
    sf::st_set_crs(4326) %>%
    dplyr::mutate(
      fill = factor(dplyr::if_else(.data$CITY_NAME == location_info$city & .data$KCITY_NAME %in% extracted_boundary$KCITY_NAME, 1, 0))
    ) %>%
    add_xy()

  if (all == TRUE) {
    return(
      list(
        community = extracted_boundary,
        community_union = extracted_boundary_union,
        ov = ov_all_map,
        lg = lg_all_map,
        pref = pref_map
      )
    )
  } else {
    return(
      extracted_boundary
    )
  }

}

find_pref_name <- function(city) {
  if (grepl("^\\d{6}$", city)) {

    matching_idx <- which(fude::lg_code_table$lg_code == city)
    pref_kanji <- fude::lg_code_table$pref_kanji[matching_idx]
    city_kanji <- fude::lg_code_table$city_kanji[matching_idx]

  } else {

    if (grepl("^[A-Za-z0-9, -]+$", city)) {

      matching_idx <- sapply(fude::pref_table$pref_code, function(x) grepl(x, city))

      if (sum(matching_idx) == 1) {
        pref_kanji <- fude::pref_table$pref_kanji[matching_idx]
        city_kanji <- toupper(gsub(paste0(get_pref_code(pref_kanji), "|,|\\s"), "", city))
      } else {
        pref_kanji <- NULL
        city_kanji <- toupper(city)
      }

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

  }

  return(list(pref = pref_kanji, city = city_kanji))
}

find_lg_code <- function(pref, city) {
  if (is.null(pref)) {

    if (grepl("^[A-Z-]+$", city)) {

      if (grepl("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", city)) {
        matching_idx <- dplyr::filter(fude::lg_code_table, .data$romaji == city)
      } else {
        matching_idx <- dplyr::filter(fude::lg_code_table, gsub("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", "", .data$romaji) == city)
      }

    } else {

      if (grepl("(\u5e02|\u533a|\u753a|\u6751)$", city)) {
        matching_idx <- dplyr::filter(fude::lg_code_table, .data$city_kanji == city)
      } else {
        matching_idx <- dplyr::filter(fude::lg_code_table, sub("(\u5e02|\u533a|\u753a|\u6751)$", "", .data$city_kanji) == city)
      }

    }

    if (nrow(matching_idx) > 1) {
      stop("Include the prefecture name in the argument 'city'.")
    }

  } else {

    if (grepl("^[A-Z-]+$", city)) {

      if (grepl("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", city, ignore.case = TRUE)) {
        matching_idx <- dplyr::filter(fude::lg_code_table, .data$pref_kanji == pref & .data$romaji == city)
      } else {
        matching_idx <- dplyr::filter(fude::lg_code_table, .data$pref_kanji == pref & gsub("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", "", .data$romaji) == city)
      }

    } else {

      if (grepl("(\u5e02|\u533a|\u753a|\u6751)$", city)) {
        matching_idx <- dplyr::filter(fude::lg_code_table, .data$pref_kanji == pref & .data$city_kanji == city)
      } else {
        matching_idx <- dplyr::filter(fude::lg_code_table, .data$pref_kanji == pref & sub("(\u5e02|\u533a|\u753a|\u6751)$", "", .data$city_kanji) == city)
      }

    }

  }

  return(matching_idx$lg_code)
}

add_xy <- function(data) {
  x <- data %>%
    dplyr::mutate(
      centroid = sf::st_centroid(.data$geometry),
      x = sf::st_coordinates(.data$centroid)[, 1],
      y = sf::st_coordinates(.data$centroid)[, 2]
    ) %>%
    sf::st_sf()

  return(x)
}

if (getRversion() >= "2.15.1") {
  utils::globalVariables(".")
}
