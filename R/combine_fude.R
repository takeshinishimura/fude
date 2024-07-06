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
#' @param year
#'   Year in the column name of the `data`. If there is more than one
#'   applicable local government code, it is required.
#' @returns A list of [sf::sf()] objects.
#' @seealso [read_fude()].
#'
#' @examplesIf interactive()
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path, stringsAsFactors = FALSE)
#' b <- get_boundary(d)
#' db <- combine_fude(d, b, "\u677e\u5c71\u5e02", "\u57ce\u6771", year = 2022)
#' @importFrom magrittr %>%
#'
#' @export
combine_fude <- function(data,
                         boundary,
                         city,
                         old_village = "",
                         community = "",
                         year = NULL) {

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

  pref_code <- substr(lg_code, start = 1, stop = 2)
  community_city <- fude::lg_code_table$city_kanji[fude::lg_code_table$lg_code == lg_code]
  community_city <- dplyr::if_else(grepl("\u533a$", community_city), sub(".*\u5e02", "", community_city), community_city)

  valid_boundary <- boundary[[pref_code]] %>%
    dplyr::rowwise() %>%
    dplyr::mutate(local_government_cd = grep(paste0("^", .data$PREF, .data$CITY, "\\d$"), fude::lg_code_table$lg_code, value = TRUE)) %>%
    dplyr::ungroup() %>%
    sf::st_make_valid()

  y <- valid_boundary %>%
    dplyr::mutate(KCITY_NAME = dplyr::if_else(is.na(.data$KCITY_NAME), "", .data$KCITY_NAME)) %>%
    dplyr::mutate(RCOM_NAME = dplyr::if_else(is.na(.data$RCOM_NAME), "", .data$RCOM_NAME)) %>%
    dplyr::filter(.data$CITY_NAME == community_city &
                  grepl(old_village, .data$KCITY_NAME, perl = TRUE) &
                  grepl(community, .data$RCOM_NAME, perl = TRUE)) %>%
    dplyr::mutate(KCITY_NAME = forcats::fct_inorder(.data$KCITY_NAME),
                  RCOM_NAME = forcats::fct_inorder(.data$RCOM_NAME),
                  RCOM_KANA = forcats::fct_inorder(.data$RCOM_KANA),
                  RCOM_ROMAJI = forcats::fct_inorder(.data$RCOM_ROMAJI)) %>%
    dplyr::mutate(centroid = sf::st_centroid(.data$geometry)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(x = sf::st_coordinates(.data$centroid)[, 1],
                  y = sf::st_coordinates(.data$centroid)[, 2]) %>%
    dplyr::ungroup() %>%
    as.data.frame() %>%
    sf::st_sf()

  intersection_fude <- sf::st_intersection(x, y)
  intersection_fude$local_government_cd.1 <- NULL

  fude_original <- x[x$polygon_uuid %in% unique(intersection_fude$polygon_uuid), ]
  fude_filtered <- intersection_fude %>%
    dplyr::filter(!duplicated(.data$polygon_uuid))
  common_cols <- intersect(names(fude_original), names(fude_filtered))
  common_cols <- setdiff(common_cols, "polygon_uuid")
  fude_selected <- fude_filtered %>%
    dplyr::select(-dplyr::one_of(common_cols)) %>%
    sf::st_set_geometry(NULL)
  fude_original <- dplyr::left_join(fude_original, fude_selected, by = "polygon_uuid")

  y_union <- y %>%
    sf::st_union() %>%
    sf::st_sf() %>%
    dplyr::mutate(centroid = sf::st_centroid(.data$geometry)) %>%
    dplyr::mutate(local_government_cd = paste0(unique(y$local_government_cd), collapse = "/"),
                  x = sf::st_coordinates(.data$centroid)[, 1],
                  y = sf::st_coordinates(.data$centroid)[, 2]) %>%
    as.data.frame() %>%
    sf::st_sf()

  geometries <- valid_boundary %>%
    sf::st_union() %>%
    sf::st_geometry()
  pref_df <- sf::st_sf(pref_code = pref_code, geometry = geometries)
  pref_df <- sf::st_set_crs(pref_df, 4326)
  pref_map <- dplyr::left_join(pref_df, fude::pref_table, by = "pref_code")

  unique_local_government_cd <- unique(valid_boundary$local_government_cd)
  geometries <- purrr::map(unique_local_government_cd,
    function(cd) {
      valid_boundary %>%
        dplyr::filter(grepl(cd, .data$local_government_cd)) %>%
        sf::st_union() %>%
        sf::st_geometry() %>%
        .[[1]]
    }) %>% do.call(sf::st_sfc, .)
  lg_df <- sf::st_sf(local_government_cd = unique_local_government_cd, geometry = geometries)
  lg_df <- sf::st_set_crs(lg_df, 4326)
  lg_ls <- ls_fude(data)[!duplicated(ls_fude(data)$local_government_cd), ]
  lg_ls <- lg_ls %>%
    dplyr::select(-c(.data$full_names, .data$year, .data$names))
  lg_all_map <- dplyr::inner_join(lg_df, lg_ls, by = "local_government_cd")

  lg_all_map <- lg_all_map %>%
    dplyr::mutate(fill = factor(dplyr::if_else(.data$city_kanji == location_info$city, 1, 0)))

  lg_map <- lg_all_map %>%
    dplyr::filter(.data$fill == 1)

  valid_boundary_KCITY_code <- valid_boundary %>%
    dplyr::mutate(KCITY_code = paste(.data$local_government_cd,
                                     .data$PREF,
                                     .data$CITY,
                                     .data$KCITY,
                                     .data$PREF_NAME,
                                     .data$CITY_NAME,
                                     .data$KCITY_NAME, sep = "_"))
  unique_KCITY <- unique(valid_boundary_KCITY_code$KCITY_code)
  geometries <- purrr::map(unique_KCITY,
    function (cd) {
      valid_boundary_KCITY_code %>%
        dplyr::filter(grepl(cd, .data$KCITY_code)) %>%
        sf::st_union() %>%
        sf::st_geometry() %>%
        .[[1]]
    }) %>% do.call(sf::st_sfc, .)
  ov_df <- sf::st_sf(KCITY_code = unique_KCITY, geometry = geometries)
  ov_df <- ov_df %>%
    tidyr::separate(.data$KCITY_code, into = c("local_government_cd",
                                               "PREF",
                                               "CITY",
                                               "KCITY",
                                               "PREF_NAME",
                                               "CITY_NAME",
                                               "KCITY_NAME"), sep = "_")
  ov_df$KCITY_NAME[ov_df$KCITY_NAME == "NA"] <- NA
  ov_all_map <- sf::st_set_crs(ov_df, 4326)

  ov_all_map <- ov_all_map %>%
    dplyr::mutate(fill = factor(dplyr::if_else(.data$CITY_NAME == location_info$city & .data$KCITY_NAME %in% y$KCITY_NAME, 1, 0)))

  ov_map <- ov_all_map %>%
    dplyr::filter(.data$fill == 1)

  message(paste(length(unique(fude_original$RCOM_NAME)), "communities have been extracted."))

  return(list(fude = fude_original,
              fude_split = intersection_fude,
              community = y,
              community_union = y_union,
#             ov = ov_map,
              ov = ov_all_map,
#             lg = lg_map,
              lg = lg_all_map,
              pref = pref_map
              )
        )
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

if (getRversion() >= "2.15.1") {
  utils::globalVariables(".")
}
