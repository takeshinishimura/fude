#' Extract specified Fude Polygon data
#'
#' @description
#' `extract_fude()` extracts the specified data from the list returned by
#' [read_fude()].
#' @param data
#'   List of [sf::sf()] objects.
#' @param year
#'   Year to be extracted.
#' @param city
#'   Local government name (or code) to be extracted.
#' @param list
#'   logical. If `FALSE`, the object to be extracted is no longer a list.
#' @returns A list of [sf::sf()] object(s).
#' @seealso [read_fude()].
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path, quiet = TRUE)
#' d2 <- extract_fude(d, year = 2022, city = "\u677e\u5c71\u5e02")
#' d |> extract_fude(year = 2022)
#' @export
extract_fude <- function(data, year = NULL, city = NULL, list = TRUE) {
  if (is.null(year) & is.null(city)) {
    stop("Specify either `year` or `city`.")
  }

  if (!is.null(city)) {

    if (is.null(year)) {
      year <- names(ls_fude(data))
    }

    selected_names <- NULL

    for (i in as.character(year)) {
      data_i <- ls_fude(data)[[i]]
      matching_idx1 <- match(city, data_i$local_government_cd)
      matching_idx2 <- match(city, data_i$city_kanji)
      matching_idx3 <- match(tolower(gsub("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", "", city, ignore.case = TRUE)),
                             tolower(gsub("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", "", data_i$romaji, ignore.case = TRUE)))
      matching_idx <- c(matching_idx1, matching_idx2, matching_idx3)
      selected_names <- c(selected_names, data_i$full_names[stats::na.omit(matching_idx)])
    }

  } else {

    selected_names <- names(data)[grep(year, names(data))]

  }

  if (list == TRUE) {

    x <- data[selected_names]

  } else {

    if (length(selected_names) > 1) {
      stop("`list` must be TRUE if there are multiple objects to be extracted.")
    }

    x <- data[[selected_names]]
  }

  return(x)
}
