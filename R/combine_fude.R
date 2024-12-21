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
#' @param kcity
#'   String by regular expression. One or more old city name in Japanese to be
#'   extracted.
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
                         kcity = "",
                         community = "",
                         year = NULL) {

  extracted_boundary <- extract_boundary(boundary = boundary,
                                         city = city,
                                         kcity = kcity,
                                         community = community,
                                         all = TRUE)

  location_info <- find_pref_name(city)
  lg_code <- find_lg_code(location_info$pref, location_info$city)

  if ("key" %in% names(data[[1]])) {

    target_key <- unique(extracted_boundary$community$KEY)
    fude_original <- data[[grepl(paste0("_", substr(lg_code, start = 1, stop = 2), "$"), names(data))]] |>
      dplyr::filter(.data$key %in% target_key)
    intersection_fude <- NULL

  } else {

    local_government_cd <- unlist(
      lapply(names(data), function(i) unique(data[[i]]$local_government_cd))
    )

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

    intersection_fude <- x |>
      sf::st_intersection(extracted_boundary$community) |>
      dplyr::select(-.data$local_government_cd.1)

    fude_original <- x[x$polygon_uuid %in% unique(intersection_fude$polygon_uuid), ]
    fude_filtered <- intersection_fude |>
      dplyr::filter(!duplicated(.data$polygon_uuid))
    common_cols <- intersect(names(fude_original), names(fude_filtered))
    common_cols <- setdiff(common_cols, "polygon_uuid")
    fude_selected <- fude_filtered |>
      dplyr::select(-dplyr::one_of(common_cols)) |>
      sf::st_set_geometry(NULL)
    fude_original <- fude_original %>%
      dplyr::left_join(fude_selected, by = "polygon_uuid") %>%
      dplyr::mutate(
        centroid = sf::st_sfc(
          purrr::map2(.data$point_lng, .data$point_lat, ~ sf::st_point(c(.x, .y))),
          crs = sf::st_crs(.)
        )
      )

    intersection_fude <- intersection_fude |>
      dplyr::mutate(
        centroid = sf::st_centroid(.data$geometry),
        point_lng = sf::st_coordinates(.data$centroid)[, 1],
        point_lat = sf::st_coordinates(.data$centroid)[, 2]
      )

  }

  message(paste(length(unique(extracted_boundary$community$KEY)), "communities have been extracted."))

  return(
    list(
      fude = fude_original,
      fude_split = intersection_fude,
      community = extracted_boundary$community,
      community_union = extracted_boundary$community_union,
      kcity = extracted_boundary$kcity,
      city = extracted_boundary$city,
      pref = extracted_boundary$pref
    )
  )
}
