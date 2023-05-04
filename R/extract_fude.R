#' Extract specified Fude Polygon data
#'
#' @description
#' `extract_fude()` extracts the specified data from the list returned by
#' [read_fude()].
#'
#' @param data
#'   List of [sf::sf()] objects.
#' @param year
#'   Year to be extracted. If both `year` and `city` are not
#'   specified, all objects for the most recent year are extracted.
#' @param city
#'   Local government name (or code) to be extracted.
#' @param list
#'   Logical. If `FALSE`, the object to be extracted is no longer a list.
#' @returns A list of [sf::sf()] object(s).
#' @seealso [read_fude()].
#'
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path)
#' d2 <- extract_fude(d, year = 2022, city = '\u677e\u5c71\u5e02')
#' d |> extract_fude(year = 2022)
#'
#' @export
extract_fude <- function(data, year = NULL, city = NULL, list = TRUE) {
  if (length(city) > 1) {
    stop("`city` must not contain more than one element.")
  }

  if (length(year) > 1) {
    stop("`year` must not contain more than one element.")
  }

  if (is.null(year)) {
    year <- max(sub("(_.*)", "", names(ls_fude(data))))

    if (!is.null(city)) {
      selected_names <- names(data)[grep(city, names(data))]
      year <- as.double(sub("(_.*)", "", selected_names))
    }

  }

  if (is.null(city)) {
    selected_names <- names(data)[grep(year, names(data))]
    city <- sub(".*_", "", selected_names)
  }

  col_name <- paste(year, city, sep = "_")

  if (list == TRUE) {
    x <- data[col_name]
  } else {

    if (length(col_name) > 1) {
      stop("`list` must be TRUE if there are multiple objects to be extracted.")
    }

    x <- data[[col_name]]
  }

  return(x)
}
