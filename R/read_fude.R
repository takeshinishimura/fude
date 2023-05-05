#' Read a Fude Polygon ZIP file
#'
#' @description
#' `read_fude()` reads Fude Polygon data as a list. The data can be downloaded
#' from the MAFF website as a ZIP file, which contains one or more GeoJSON
#' format files. The function should also work with the ZIP file you created,
#' as long as you do not change the filenames of the original GeoJSON files.
#' @param path
#'   Path to the ZIP file containing one or more GeoJSON format files.
#' @returns A list of [sf::sf()] objects.
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path)
#' @export
read_fude <- function(path) {
  if (!grepl(".zip$", path)) {
    stop(path, " is not a ZIP file.")
  }

  exdir <- tempfile()
  on.exit(unlink(exdir, recursive = TRUE))
  utils::unzip(path, exdir = exdir)
  json_files <- list.files(exdir, pattern = "\\.json$|\\.geojson$", recursive = TRUE, full.names = TRUE)

  if (length(json_files) == 0) {
    stop("There is no GeoJSON format file in ", path, ".")
  }

  x <- lapply(json_files, sf::st_read)
  names(x) <- gsub("^.*/|.json", "", json_files)

  return(x)
}
