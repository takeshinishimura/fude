#' Extract specified agricultural community boundary data
#'
#' @description
#' `extract_boundary()` extracts specified subsets of agricultural community
#' boundary data returned by [get_boundary()].
#'
#' @param boundary
#'   Agricultural community boundary data as returned by [get_boundary()].
#' @param city
#'   A character vector of local government names or 6-digit local government
#'   codes to extract.
#' @param kcity
#'   A regular expression. One or more former municipality names (in Japanese)
#'   to extract.
#' @param rcom
#'   A regular expression. One or more agricultural community names (in
#'   Japanese) to extract.
#' @param layer
#'   Logical. If `TRUE`, the returned object includes not only agricultural
#'   community boundaries but also prefecture and municipality boundaries.
#'
#' @returns
#'   An [sf::sf()] object.
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

    target_city_list <- lapply(
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

    target_city <- vapply(target_city_list, `[[`, character(1), "target_city")
    target_pref_code <- vapply(target_city_list, `[[`, character(1), "pref_code")[1]
  } else {
    target_pref_code <- boundary |>
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
    dplyr::bind_rows()

  if (!any(target_key %in% x$key)) {
    target_key <- unique(sub("\\d{3}$", "000", target_key))# boundary_type == 2

    if (!any(target_key %in% x$key)) {
      target_key <- unique(sub("\\d{5}$", "00000", target_key))# boundary_type == 3

      if (!any(target_key %in% x$key)) {
        stop("Can't find the target boundary.")
      }
    }
  }

  x <- x |>
    dplyr::filter(.data$pref %in% target_pref_code) |>
  # add_local_government_cd_to_df() |>
    sf::st_make_valid()

  extracted <- x |>
    dplyr::filter(.data$key %in% target_key) |>
    dplyr::arrange(.data$key) |>
    dplyr::mutate(
      pref_name = droplevels(.data$pref_name),
      city_name = droplevels(.data$city_name),
      kcity_name = droplevels(.data$kcity_name),
      rcom_name = droplevels(.data$rcom_name),
      pref_kana = droplevels(.data$pref_kana),
      city_kana = droplevels(.data$city_kana),
      rcom_kana = droplevels(.data$rcom_kana),
      pref_romaji = droplevels(.data$pref_romaji),
      city_romaji = droplevels(.data$city_romaji),
      rcom_romaji = droplevels(.data$rcom_romaji)
    ) |>
    add_xy()

  if (isFALSE(layer)) {
    message(
      nrow(extracted), " ",
      if (!any(extracted$rcom == "000")) "communities" else "municipalities",
      " have been extracted."
    )

    return(extracted)
  }

  crs <- sf::st_crs(extracted)

  extracted_union <- extracted |>
    sf::st_union() |>
    sf::st_sf(geometry = _) |>
    dplyr::as_tibble() |>
    sf::st_as_sf() |>
    add_xy()

  geometries <- x |>
    sf::st_union() |>
    sf::st_geometry()

  pref_map <- sf::st_sf(
    pref_code = fude_to_pref_code(x),
    geometry = geometries
  ) |>
    sf::st_set_crs(crs) |>
    dplyr::left_join(fude::pref_code_table, by = "pref_code") |>
    add_xy()

  all_city <- unique(x$city)

  geometries <- lapply(
    all_city,
    \(d) {
      sf::st_geometry(
        x |>
          dplyr::filter(.data$city == d) |>
          sf::st_union()
      )[[1]]
    }
  )

  city_map <- sf::st_sf(
    local_government_cd = unique(modulus11(x$key)),
    geometry = geometries
  ) |>
    sf::st_set_crs(crs) |>
    dplyr::left_join(
      fude::city_code_table |>
        dplyr::select(
          .data$key,
          .data$pref_name, .data$city_name,
          .data$pref_kana, .data$city_kana,
          .data$pref_romaji, .data$city_romaji,
          .data$local_government_cd
        ),
      by = "local_government_cd"
    ) |>
    dplyr::select(-.data$local_government_cd) |>
    dplyr::mutate(
      fill = factor(
        dplyr::if_else(
          .data$city_name %in% extracted$city_name,
          1,
          0
        )
      )
    ) |>
    dplyr::as_tibble() |>
    sf::st_as_sf() |>
    add_xy()

  x_kcity_code <- x |>
    dplyr::mutate(
      kcity_code = paste0(
        .data$pref,
        .data$city,
        .data$kcity
      )
    )
  unique_kcity_code <- unique(x_kcity_code$kcity_code)
  geometries <- lapply(
    unique_kcity_code,
    \(d) {
      sf::st_geometry(
        x_kcity_code |>
          dplyr::filter(.data$kcity_code == d) |>
          sf::st_union()
      )[[1]]
    }
  )

  kcity_map <- sf::st_sf(
    key = paste0(unique_kcity_code, "000"),
    geometry = geometries
  ) |>
    sf::st_set_crs(crs) |>
    dplyr::left_join(
      fude::kcity_code_table |>
        dplyr::select(
          .data$key,
          .data$pref_name, .data$city_name,
          .data$kcity_name,
          .data$pref_kana, .data$city_kana,
          .data$pref_romaji, .data$city_romaji
        ),
      by = "key"
    ) |>
    dplyr::mutate(
      fill = factor(
        dplyr::if_else(
          .data$kcity_name %in% extracted$kcity_name,
          1,
          0
        )
      )
    ) |>
    dplyr::as_tibble() |>
    sf::st_as_sf() |>
    add_xy()

  message(
    nrow(extracted), " ",
    if (!any(extracted$rcom == "000")) "communities" else "municipalities",
    " have been extracted."
  )

  return(
    list(
      rcom = extracted,
      rcom_union = extracted_union,
      kcity = kcity_map,
      city = city_map,
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
        city_kanji <- gsub(paste0("^", pref_kanji, "|\\s|\u3000"), "", city)
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
  coords <- suppressWarnings(
    sf::st_coordinates(
      sf::st_point_on_surface(
        data
      )
    )
  )

  data |>
    dplyr::mutate(
      x = coords[, "X"],
      y = coords[, "Y"]
    )
}

if (getRversion() >= "2.15.1") {
  utils::globalVariables(".")
}

utils::globalVariables("location_info")
