#' Extract specified Fude Polygon data
#'
#' @description
#' `extract_fude()` extracts the specified data from the list returned by
#' [read_fude()].
#' @param data
#'   List of [sf::sf()] objects.
#' @param year
#'   Years to be extracted.
#' @param city
#'   Local government names or codes to be extracted.
#' @param list
#'   logical. If `FALSE`, the object to be extracted is no longer a list.
#' @param kcity
#'   String by regular expression. One or more former village name in Japanese
#'   to be extracted.
#' @param community
#'   String by regular expression. One or more agricultural community name in
#'   Japanese to be extracted.
#' @returns A list of [sf::sf()] object(s).
#' @seealso [read_fude()].
#'
#' @export
extract_fude <- function(data,
                         year = NULL,
                         city = NULL,
                         kcity = "",
                         community = "",
                         list = TRUE) {

  if (is.null(year) & is.null(city)) {
    stop("Specify either `year` or `city`.")
  }

  if (!is.null(city)) {

    if (is.null(year)) {
      year <- unique(ls_fude(data)$issue_year)
    }

    selected_names <- NULL

    for (i in year) {
      ls_data <- ls_fude(data) |>
        dplyr::filter(.data$issue_year == i)

      matching_idx1 <- match(city, ls_data$local_government_cd)
      matching_idx2 <- match(
        sub("(\u5e02|\u533a|\u753a|\u6751)$", "", city),
        sub("(\u5e02|\u533a|\u753a|\u6751)$", "", ls_data$CITY_NAME)
      )
      matching_idx3 <- match(
        tolower(gsub("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", "", city, ignore.case = TRUE)),
        tolower(gsub("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", "", ls_data$CITY_ROMAJI, ignore.case = TRUE))
      )
      matching_idx4 <- match(city, ls_data$CITY_NAME)

      matching_idx <- unique(c(matching_idx1, matching_idx2, matching_idx3, matching_idx4))

      selected_names <- c(selected_names, ls_data$names[stats::na.omit(matching_idx)])
    }


  } else {

    selected_names <- ls_fude(data) |>
      dplyr::filter(.data$issue_year == year) |>
      dplyr::pull(.data$names)

  }

  x <- dplyr::bind_rows(data[names(data) %in% selected_names])

  if ("key" %in% names(x)) {

    target_community_key <- fude::community_code_table |>
      dplyr::filter(grepl(kcity, .data$KCITY_NAME)) |>
      dplyr::filter(grepl(community, .data$RCOM_NAME)) |>
      dplyr::pull(.data$KEY)

    x <- x |>
      dplyr::filter(.data$key %in% target_community_key)

  }

  return(x)
}
