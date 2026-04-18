#' Extract specified agricultural community boundary data
#'
#' @description
#' `extract_boundary()` extracts subsets of agricultural community boundary data
#' returned by [get_boundary()] by municipality, former municipality, and/or
#' agricultural community.
#'
#' @param boundary
#'   Agricultural community boundary data returned by [get_boundary()].
#' @param city
#'   A character vector of municipality names or local government codes used to
#'   identify target municipalities. If `NULL`, all municipalities are kept.
#' @param kcity
#'   A character vector of regular expression patterns used to match former
#'   municipality names in Japanese.
#' @param rcom
#'   A character vector of regular expression patterns used to match agricultural
#'   community names in Japanese.
#' @param layer
#'   Logical. If `TRUE`, return a list containing extracted agricultural community
#'   boundaries together with former municipality, municipality, and prefecture
#'   boundary layers.
#'
#' @returns
#'   If `layer = FALSE`, an [sf::sf()] object. If `layer = TRUE`, a named list of
#'   [sf::sf()] objects.
#'
#' @seealso [get_boundary()]
#'
#' @export
extract_boundary <- function(
  boundary,
  city = "",
  kcity = "",
  rcom = "",
  layer = FALSE
) {
  target_key <- find_key(
    city = city,
    kcity = kcity,
    rcom = rcom
  )

  x <- if (is.data.frame(boundary)) {
    boundary
  } else if (is.list(boundary)) {
    dplyr::bind_rows(boundary)
  } else {
    stop("`boundary` must be an sf object or a list of sf objects.")
  }

  if (!("key" %in% names(x))) {
    stop("`boundary` must contain a `key` column.")
  }

  if (!any(target_key %in% x$key)) {
    target_key <- unique(sub("\\d{3}$", "000", target_key))

    if (!any(target_key %in% x$key)) {
      target_key <- unique(sub("\\d{5}$", "00000", target_key))

      if (!any(target_key %in% x$key)) {
        stop("Can't find the target boundary.")
      }
    }
  }

  x <- x |>
    sf::st_make_valid()

  extracted <- x |>
    dplyr::filter(.data$key %in% target_key) |>
    dplyr::arrange(.data$key) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of(c(
          "pref_name", "city_name", "kcity_name", "rcom_name",
          "pref_kana", "city_kana", "rcom_kana",
          "pref_romaji", "city_romaji", "rcom_romaji"
        )),
        ~ if (is.factor(.x)) droplevels(.x) else .x
      )
    ) |>
    add_xy()

  extracted_type <- if (!any(extracted$rcom == "000")) {
    "communities"
  } else {
    "municipalities"
  }

  if (isFALSE(layer)) {
    message(nrow(extracted), " ", extracted_type, " have been extracted.")
    return(extracted)
  }

  boundary_crs <- sf::st_crs(extracted)

  extracted_union <- extracted |>
    sf::st_union() |>
    sf::st_sf(geometry = _) |>
    dplyr::as_tibble() |>
    sf::st_as_sf() |>
    add_xy()

  pref_geometries <- x |>
    sf::st_union() |>
    sf::st_geometry()

  pref_map <- sf::st_sf(
    pref = fude_to_pref_code(x),
    geometry = pref_geometries
  ) |>
    sf::st_set_crs(boundary_crs) |>
    dplyr::left_join(fude::pref_code_table, by = "pref") |>
    add_xy()

  all_city <- unique(x$city)

  city_geometries <- lapply(
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
    geometry = city_geometries
  ) |>
    sf::st_set_crs(boundary_crs) |>
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
      fill = factor(dplyr::if_else(.data$city_name %in% extracted$city_name, 1, 0))
    ) |>
    dplyr::as_tibble() |>
    sf::st_as_sf() |>
    add_xy()

  x_kcity_code <- x |>
    dplyr::mutate(
      kcity_code = paste0(.data$pref, .data$city, .data$kcity)
    )

  unique_kcity_code <- unique(x_kcity_code$kcity_code)

  kcity_geometries <- lapply(
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
    geometry = kcity_geometries
  ) |>
    sf::st_set_crs(boundary_crs) |>
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
      fill = factor(dplyr::if_else(.data$kcity_name %in% extracted$kcity_name, 1, 0))
    ) |>
    dplyr::as_tibble() |>
    sf::st_as_sf() |>
    add_xy()

  message(nrow(extracted), " ", extracted_type, " have been extracted.")

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
  city <- as.character(city)[1]

  if (grepl("^\\d{6}$", city)) {
    matching_idx <- which(fude::lg_code_table$lg_code == city)
    pref_kanji <- fude::lg_code_table$pref_kanji[matching_idx]
    city_kanji <- fude::lg_code_table$city_kanji[matching_idx]
  } else if (grepl("^[A-Za-z0-9, -]+$", city)) {
    matching_idx <- vapply(
      fude::pref_code_table$pref,
      \(x) grepl(x, city),
      logical(1)
    )

    if (sum(matching_idx) == 1) {
      pref_kanji <- fude::pref_code_table$pref_name[matching_idx]
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
    matching_idx <- vapply(
      fude::pref_code_table$pref_name,
      \(x) grepl(paste0("^", x), city),
      logical(1)
    )

    if (sum(matching_idx) == 1) {
      pref_kanji <- fude::pref_code_table$pref_name[matching_idx]
      city_kanji <- gsub(paste0("^", pref_kanji, "|\\s|\u3000"), "", city)
    } else {
      pref_kanji <- NULL
      city_kanji <- city
    }
  }

  return(list(pref = pref_kanji, city = city_kanji))
}

find_lg_code <- function(pref, city) {
  if (is.null(pref)) {
    if (grepl("^[A-Z-]+$", city)) {
      if (grepl("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", city, ignore.case = TRUE)) {
        matching_idx <- dplyr::filter(fude::lg_code_table, .data$romaji == city)
      } else {
        matching_idx <- dplyr::filter(
          fude::lg_code_table,
          gsub("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", "", .data$romaji) == city
        )
      }
    } else {
      if (grepl("(\u5e02|\u533a|\u753a|\u6751)$", city)) {
        matching_idx <- dplyr::filter(fude::lg_code_table, .data$city_kanji == city)
      } else {
        matching_idx <- dplyr::filter(
          fude::lg_code_table,
          sub("(\u5e02|\u533a|\u753a|\u6751)$", "", .data$city_kanji) == city
        )
      }
    }

    if (nrow(matching_idx) > 1) {
      stop("Include the prefecture name in the argument `city`.")
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

  matching_idx$lg_code
}

add_xy <- function(data) {
  coords <- suppressWarnings(
    sf::st_coordinates(
      sf::st_centroid(data)
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
