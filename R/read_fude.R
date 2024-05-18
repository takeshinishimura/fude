#' Read a Fude Polygon ZIP file
#'
#' @description
#' `read_fude()` reads Fude Polygon data as a list. The data can be downloaded
#' from the MAFF website as a ZIP file, which contains one or more GeoJSON
#' format files. The function should also work with the ZIP file you created,
#' as long as you do not change the filenames of the original GeoJSON files.
#' @param path
#'   Path to the ZIP file containing one or more GeoJSON format files.
#' @param stringsAsFactors
#'   logical. Should character vectors be converted to factors?
#' @param quiet
#'   logical. Suppress information about the data to be read.
#' @param supplementary
#'   logical. If TRUE, add supplementary information for each polygon. Default
#'   is TRUE.
#' @returns A list of [sf::sf()] objects.
#'
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path, stringsAsFactors = FALSE)
#'
#' @export
read_fude <- function(path,
                      stringsAsFactors = TRUE,
                      quiet = FALSE,
                      supplementary = TRUE) {

  if (!grepl(".zip$", path)) {
    stop(path, " is not a ZIP file.")
  }

  exdir <- tempfile()
  on.exit(unlink(exdir, recursive = TRUE))
  utils::unzip(path, exdir = exdir)
  json_files <- list.files(exdir, pattern = "\\.json$|\\.geojson$", recursive = TRUE, full.names = TRUE)

  if (length(json_files) == 0) {
    stop("There is no GeoJSON format file in ", path, ".", call. = FALSE)
  }

  x <- lapply(json_files, sf::st_read, quiet = quiet)
  names(x) <- gsub("^.*/|.json", "", json_files)

  if (stringsAsFactors == TRUE) {
    x <- purrr::map(x, function(df) {
      df$land_type <- factor(df$land_type,
                             levels = c(100, 200))
      df$land_type_jp <- df$land_type
      levels(df$land_type_jp) <- c("\u7530", "\u7551")

      return(df)
    })
  }

  if (supplementary == TRUE) {
    for (i in names(x)) {
      x[[i]]$area <- sf::st_area(x[[i]])
      x[[i]]$a <- units::set_units(x[[i]]$area, "a")
      x[[i]]$owner <- ""
      x[[i]]$farmer <- ""
    }
  }

  return(x)
}
