#' Combine Fude Polygon data with agricultural community boundary data
#'
#' @description
#' `combine_fude()` combines Fude Polygon data with agricultural community
#' boundary data and returns the polygons associated with the specified
#' municipality, former municipality, and/or agricultural community.
#'
#' @param data
#'   A Fude Polygon data object returned by [read_fude()].
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
#' @param year
#'   Numeric scalar or `NULL`. When multiple Fude Polygon datasets match the
#'   specified municipality, `year` is used to choose the target dataset.
#'
#' @returns
#'   A named list of [sf::sf()] objects.
#'
#' @seealso [read_fude()], [get_boundary()]
#'
#' @examplesIf interactive()
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path)
#' b <- get_boundary(d)
#' db <- combine_fude(d, b, "\u677e\u5c71\u5e02", "\u57ce\u6771", year = 2022)
#'
#' @export
combine_fude <- function(
  data,
  boundary,
  city,
  kcity = "",
  rcom = "",
  year = NULL
) {
  validate_fude(data)

  x <- if (is.data.frame(data)) {
    data
  } else if (is.list(data)) {
    dplyr::bind_rows(data)
  } else {
    stop("`data` must be a data.frame or a list.")
  }

  boundary_all <- dplyr::bind_rows(boundary)

  if (sf::st_crs(x)$epsg != sf::st_crs(boundary_all)$epsg) {
    stop("CRS of `data` and `boundary` are inconsistent.")
  }

  extracted <- extract_boundary(
    boundary = boundary,
    city = city,
    kcity = kcity,
    rcom = rcom,
    layer = TRUE
  )

  boundary_crs <- sf::st_crs(extracted$rcom)

  location_info <- find_pref_name(city)
  lg_code <- find_lg_code(location_info$pref, location_info$city)

  if ("key" %in% names(x)) {
    target_key <- unique(extracted$rcom$key)

    join_data <- extracted$rcom |>
      sf::st_set_geometry(NULL)

    fude_original <- x |>
      dplyr::filter(.data$key %in% target_key) |>
      dplyr::left_join(join_data, by = "key") |>
      dplyr::mutate(
        centroid = sf::st_sfc(
          mapply(
            \(lng, lat) sf::st_point(c(lng, lat)),
            .data$point_lng,
            .data$point_lat,
            SIMPLIFY = FALSE
          ),
          crs = boundary_crs
        )
      )

    result <- list(
      fude = fude_original,
      rcom = extracted$rcom,
      rcom_union = extracted$rcom_union,
      kcity = extracted$kcity,
      city = extracted$city,
      pref = extracted$pref
    )
  } else {
    local_government_cd <- unlist(
      lapply(data, \(i) unique(i$local_government_cd)),
      use.names = FALSE
    )

    data_no <- which(local_government_cd %in% lg_code)

    if (length(data_no) != 1) {
      if (is.null(year)) {
        stop(
          "Specify `year` because multiple applicable local government codes were found."
        )
      }

      target_names <- names(data)[data_no]
      matched <- sub("(_.*)", "", target_names) == as.character(year)
      data_no <- data_no[matched]

      if (length(data_no) != 1) {
        stop("Specify the correct `year`.")
      }
    }

    target_fude <- data[[data_no]]

    intersection_fude <- target_fude |>
      sf::st_intersection(extracted$rcom)

    fude_original <- target_fude[
      target_fude$polygon_uuid %in% unique(intersection_fude$polygon_uuid),
    ]

    fude_filtered <- intersection_fude |>
      dplyr::filter(!duplicated(.data$polygon_uuid))

    common_cols <- setdiff(
      intersect(names(fude_original), names(fude_filtered)),
      "polygon_uuid"
    )

    fude_selected <- fude_filtered |>
      dplyr::select(-dplyr::any_of(common_cols)) |>
      sf::st_set_geometry(NULL)

    fude_original <- fude_original |>
      dplyr::left_join(fude_selected, by = "polygon_uuid") |>
      dplyr::mutate(
        centroid = sf::st_sfc(
          mapply(
            \(lng, lat) sf::st_point(c(lng, lat)),
            .data$point_lng,
            .data$point_lat,
            SIMPLIFY = FALSE
          ),
          crs = sf::st_crs(fude_original)
        )
      )

    intersection_fude <- intersection_fude |>
      dplyr::mutate(
        centroid = sf::st_centroid(.data$geometry),
        point_lng = sf::st_coordinates(.data$centroid)[, 1],
        point_lat = sf::st_coordinates(.data$centroid)[, 2]
      )

    result <- list(
      fude = fude_original,
      fude_split = intersection_fude,
      rcom = extracted$rcom,
      rcom_union = extracted$rcom_union,
      kcity = extracted$kcity,
      city = extracted$city,
      pref = extracted$pref
    )
  }

  return(result)
}
