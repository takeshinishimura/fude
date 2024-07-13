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
    stop("There is no GeoJSON format file in ", path, ".")
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
      pref_code <- regmatches(i, regexpr("(?<=\\d{4}_)\\d{2}", i, perl = TRUE))
      crs <- get_plane_rectangular_cs(pref_code)
      x[[i]]$area <- sf::st_area(x[[i]] |> sf::st_transform(crs = crs))
      x[[i]]$a <- as.numeric(units::set_units(x[[i]]$area, "a"))
      x[[i]]$farmland_name <- ""
      x[[i]]$owner <- ""
      x[[i]]$farmer <- ""
      x[[i]]$crop <- ""
    }
  }

  return(x)
}

get_plane_rectangular_cs <- function(pref_code) {
  cs_mapping <- list(
    "01" = 6669,
    "02" = 6668,
    "03" = 6667,
    "04" = 6666,
    "05" = 6666,
    "06" = 6665,
    "07" = 6665,
    "08" = 6665,
    "09" = 6665,
    "10" = 6664,
    "11" = 6664,
    "12" = 6664,
    "13" = 6664,
    "14" = 6664,
    "15" = 6663,
    "16" = 6663,
    "17" = 6663,
    "18" = 6663,
    "19" = 6662,
    "20" = 6662,
    "21" = 6661,
    "22" = 6661,
    "23" = 6661,
    "24" = 6660,
    "25" = 6660,
    "26" = 6660,
    "27" = 6660,
    "28" = 6660,
    "29" = 6660,
    "30" = 6660,
    "31" = 6670,
    "32" = 6670,
    "33" = 6670,
    "34" = 6670,
    "35" = 6671,
    "36" = 6673,
    "37" = 6673,
    "38" = 6673,
    "39" = 6673,
    "40" = 6671,
    "41" = 6671,
    "42" = 6671,
    "43" = 6672,
    "44" = 6672,
    "45" = 6672,
    "46" = 6672,
    "47" = 6694
  )

  return(cs_mapping[[as.character(pref_code)]])
}
