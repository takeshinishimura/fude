#' Get the agricultural community boundary data
#'
#' @description
#' `get_boundary()` downloads and reads one or more agricultural community
#' boundary data provided by the MAFF.
#' @param data
#'   List of [sf::sf()] objects.
#' @param year
#'   Year in which the agricultural community boundary data was created.
#' @param quiet
#'   logical. Suppress information about the data to be read.
#' @param to_wgs84
#'   logical. Convert JGD2000 to WGS 84.
#' @returns A list of [sf::sf()] objects.
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path)
#' b <- get_boundary(d)
#' @export
get_boundary <- function(data, year = 2020, quiet = FALSE, to_wgs84 = TRUE) {
  pref_codes <- fude_to_pref_code(data)

  x <- lapply(pref_codes, function(i) {
    pref_code <- get_pref_code(i)
    read_boundary(pref_code, year, quiet, to_wgs84)
  })

  names(x) <- pref_codes

  return(x)
}

read_boundary <- function(pref_code, year, quiet, to_wgs84) {
  url <- sprintf("https://www.machimura.maff.go.jp/shurakudata/%s/ma/MA0001_%s_%s_%s.zip",
                 year, year, year, pref_code)

  zipfile <- tempfile(fileext = ".zip")
  utils::download.file(url, zipfile)

  exdir <- tempdir()
  utils::unzip(zipfile, exdir = exdir)

  shp_files <- list.files(exdir, pattern = "\\.shp$", recursive = TRUE, full.names = TRUE)

  on.exit({
    unlink(zipfile)
    unlink(shp_files)
  })

  if (length(shp_files) != 1) {

    stop(ifelse(length(shp_files) > 1, "Multiple shapefiles found.", "No shapefile found in the ZIP archive."))
  }

  x <- sf::st_read(shp_files, quiet = quiet, options = "ENCODING=CP932")

  # Convert JGD2000 to WGS 84
  if (sf::st_crs(x)$epsg != 4326 && to_wgs84 == TRUE) {

    x <- sf::st_transform(x, crs = 4326)

  }

  return(x)
}

fude_to_pref_code <- function(data) {
  local_government_cd <- unlist(lapply(names(data),
                                       function(i) unique(data[[i]]$local_government_cd)))

  x <- unique(substr(local_government_cd, start = 1, stop = 2))

  return(x)
}

get_pref_code <- function(input) {
  if (input %in% fude::pref_table$pref_code) {

    return(input)

  } else if (input %in% fude::pref_table$pref_name) {

    return(fude::pref_table$pref_code[fude::pref_table$pref_name == input])

  } else {

    stop("Invalid input. Please enter a valid prefecture name or code.")

  }

}