#' Extract specified agricultural community boundary data
#'
#' @description
#' `extract_boundary()` extracts the specified data from the list returned by
#' [get_boundary()].
#'
#' @param boundary
#'   List of one or more MAFF agricultural community boundary data.
#' @param city
#'   A local government name in Japanese to be extracted. In the case of
#'   overlapping local government names, this must contain the prefecture name
#'   in Japanese and the prefecture code in romaji (e.g., "Fuchu-shi, 13",
#'   "fuchu 13",  "34 fuchu-shi",  "34, FUCHU-CHO"). Alternatively, it could be
#'   a 6-digit local government code.
#' @param kcity
#'   A regular expression string. One or more former city names (in Japanese)
#'   to extract.
#' @param rcom
#'   A regular expression string. One or more agricultural community names (in
#'   Japanese) to extract.
#' @param layer
#'   Logical.
#'
#' @returns A list of [sf::sf()] object(s).
#'
#' @seealso [read_fude()].
#'
#' @export
extract_boundary <- function(
  boundary,
  city = "",
  kcity = "",
  rcom = "",
  layer = FALSE
) {
  if (city != "") {
    city_list <- strsplit(city, "\\|")[[1]]

    target_city_list <- purrr::map(
      city_list,
      \(d) {
        location_info <- find_pref_name(d)
        lg_code <- find_lg_code(location_info$pref, location_info$city)
        pref_code <- fude_to_pref_code(lg_code)

        city_name <- fude::lg_code_table$city_kanji[
          fude::lg_code_table$lg_code == lg_code
        ]
        city_name <- dplyr::if_else(
          grepl("\u533a$", city_name),
          sub(".*\u5e02", "", city_name),
          city_name
        )

        return(list(target_city = city_name, pref_code = pref_code))
      }
    )

    target_city <- purrr::map_chr(target_city_list, "target_city")
    pref_code <- purrr::map_chr(target_city_list, "pref_code")[1]
  } else {
    pref_code <- boundary |>
      dplyr::bind_rows() |>
      dplyr::pull(.data$pref) |>
      unique()
    target_city <- ""
  }

  target_key <- find_key(
    city = city,
    kcity = kcity,
    rcom = rcom
  )

  x <- boundary |>
    dplyr::bind_rows() |>
    dplyr::filter(.data$pref %in% pref_code) |>
    add_local_government_cd_to_df() |>
    sf::st_make_valid()

  extracted_boundary <- x |>
    dplyr::filter(.data$key %in% target_key) |>
    dplyr::arrange(.data$key) |>
    dplyr::mutate(
      kcity_name = dplyr::coalesce(.data$kcity_name, ""),
      rcom_name = dplyr::coalesce(.data$rcom_name, "")
    ) |>
    dplyr::mutate(
      kcity_name = factor(.data$kcity_name, levels = unique(.data$kcity_name)),
      rcom_name = factor(.data$rcom_name, levels = unique(.data$rcom_name)),
      rcom_kana = factor(.data$rcom_kana, levels = unique(.data$rcom_kana)),
      rcom_romaji = factor(.data$rcom_romaji, levels = unique(.data$rcom_romaji))
    ) |>
    add_xy()

  extracted_boundary_union <- extracted_boundary |>
    sf::st_union() |>
    sf::st_sf() |>
    dplyr::mutate(
      local_government_cd = paste0(
        unique(extracted_boundary$local_government_cd),
        collapse = "/"
      )
    ) |>
    add_xy()

  geometries <- x |>
    sf::st_union() |>
    sf::st_geometry()

  pref_map <- sf::st_sf(
    pref_code = fude_to_pref_code(x),
    geometry = geometries
  ) |>
    sf::st_set_crs(4326) |>
    dplyr::left_join(fude::pref_code_table, by = "pref_code") |>
    add_xy()

  unique_local_government_cd <- unique(x$local_government_cd)
  geometries <- purrr::map(
    unique_local_government_cd,
    \(d) {
      x |>
        dplyr::filter(grepl(d, .data$local_government_cd)) |>
        sf::st_union() |>
        sf::st_geometry() %>%
        .[[1]]
    }
  ) %>%
    do.call(sf::st_sfc, .)
  city_df <- sf::st_sf(
    local_government_cd = unique_local_government_cd,
    geometry = geometries
  ) |>
    sf::st_set_crs(4326)
  city_ls <- fude::lg_code_table |>
    dplyr::filter(.data$lg_code %in% unique_local_government_cd) |>
    dplyr::select(
      local_government_cd = .data$lg_code,
      .data$pref_kanji,
      .data$city_kanji,
      .data$romaji
    )
  city_all_map <- dplyr::inner_join(
    city_df,
    city_ls,
    by = "local_government_cd"
  )

  if (city != "") {
    city_all_map <- city_all_map |>
      dplyr::mutate(
        fill = factor(dplyr::if_else(.data$city_kanji %in% target_city, 1, 0))
      )
  }

  city_all_map <- city_all_map |>
    add_xy()

  x_KCITY_code <- x |>
    dplyr::mutate(
      KCITY_code = paste(
        .data$local_government_cd,
        .data$pref,
        .data$city,
        .data$kcity,
        .data$pref_name,
        .data$city_name,
        .data$kcity_name,
        sep = "_"
      )
    )
  unique_KCITY <- unique(x_KCITY_code$KCITY_code)
  geometries <- purrr::map(
    unique_KCITY,
    \(d) {
      x_KCITY_code |>
        dplyr::filter(grepl(d, .data$KCITY_code)) |>
        sf::st_union() |>
        sf::st_geometry() %>%
        .[[1]]
    }
  ) %>%
    do.call(sf::st_sfc, .)
  kcity_df <- sf::st_sf(KCITY_code = unique_KCITY, geometry = geometries) |>
    tidyr::separate(
      .data$KCITY_code,
      into = c(
        "local_government_cd",
        "pref",
        "city",
        "kcity",
        "pref_name",
        "city_name",
        "kcity_name"
      ),
      sep = "_"
    )
  kcity_df$kcity_name[kcity_df$kcity_name == "NA"] <- NA
  kcity_all_map <- kcity_df |>
    sf::st_set_crs(4326)

  if (city != "") {
    kcity_all_map <- kcity_all_map |>
      dplyr::mutate(
        fill = factor(dplyr::if_else(
          .data$city_name %in%
            target_city &
            .data$kcity_name %in% extracted_boundary$kcity_name,
          1,
          0
        ))
      )
  }

  kcity_all_map <- kcity_all_map |>
    add_xy()

  if (layer) {
    return(
      list(
        rcom = extracted_boundary,
        rcom_union = extracted_boundary_union,
        kcity = kcity_all_map,
        city = city_all_map,
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
      matching_idx <- sapply(fude::pref_code_table$pref_code, function(x) {
        grepl(x, city)
      })

      if (sum(matching_idx) == 1) {
        pref_kanji <- fude::pref_code_table$pref_kanji[matching_idx]
        city_kanji <- toupper(gsub(
          paste0(get_pref_code(pref_kanji), "|,|\\s"),
          "",
          city
        ))
      } else {
        pref_kanji <- NULL
        city_kanji <- toupper(city)
      }
    } else {
      matching_idx <- sapply(fude::pref_code_table$pref_kanji, function(x) {
        grepl(paste0("^", x), city)
      })

      if (sum(matching_idx) == 1) {
        pref_kanji <- fude::pref_code_table$pref_kanji[matching_idx]
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
        matching_idx <- dplyr::filter(
          fude::lg_code_table,
          gsub("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", "", .data$romaji) == city
        )
      }
    } else {
      if (grepl("(\u5e02|\u533a|\u753a|\u6751)$", city)) {
        matching_idx <- dplyr::filter(
          fude::lg_code_table,
          .data$city_kanji == city
        )
      } else {
        matching_idx <- dplyr::filter(
          fude::lg_code_table,
          sub("(\u5e02|\u533a|\u753a|\u6751)$", "", .data$city_kanji) == city
        )
      }
    }

    if (nrow(matching_idx) > 1) {
      stop("Include the prefecture name in the argument 'city'.")
    }
  } else {
    if (grepl("^[A-Z-]+$", city)) {
      if (grepl("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", city, ignore.case = TRUE)) {
        matching_idx <- dplyr::filter(
          fude::lg_code_table,
          .data$pref_kanji == pref & .data$romaji == city
        )
      } else {
        matching_idx <- dplyr::filter(
          fude::lg_code_table,
          .data$pref_kanji == pref &
            gsub("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", "", .data$romaji) == city
        )
      }
    } else {
      if (grepl("(\u5e02|\u533a|\u753a|\u6751)$", city)) {
        matching_idx <- dplyr::filter(
          fude::lg_code_table,
          .data$pref_kanji == pref & .data$city_kanji == city
        )
      } else {
        matching_idx <- dplyr::filter(
          fude::lg_code_table,
          .data$pref_kanji == pref &
            sub("(\u5e02|\u533a|\u753a|\u6751)$", "", .data$city_kanji) == city
        )
      }
    }
  }

  return(matching_idx$lg_code)
}

add_xy <- function(data) {
  centroid <- sf::st_coordinates(sf::st_centroid(sf::st_geometry(data)))

  data |>
    dplyr::mutate(
      x = centroid[, 1],
      y = centroid[, 2]
    )
}

if (getRversion() >= "2.15.1") {
  utils::globalVariables(".")
}

utils::globalVariables("location_info")
