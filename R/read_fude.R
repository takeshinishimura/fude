#' Read a Fude Polygon ZIP file
#'
#' @description
#' `read_fude()` reads Fude Polygon data as a list. The data can be downloaded
#' from the MAFF website as a ZIP file, which contains one or more spatial data
#' files, such as **GeoJSON** files (`.json` or `.geojson`) and **FlatGeobuf**
#' files (`.fgb`). The function also works with ZIP files you created, as long
#' as you do not change the filenames of the original files.
#' @param path
#'   Path to the ZIP file containing one or more supported spatial data files.
#'   Supported formats include `.geojson`, `.json`, and `.fgb`.
#' @param pref
#'   The year when the Fude Polygon data was created.
#' @param year
#'   The year when the Fude Polygon data was created.
#' @param census_year
#'   The year of the Agricultural and Forestry Census.
#' @param stringsAsFactors
#'   logical. Should character vectors be converted to factors?
#' @param to_wgs84
#'   logical. Convert JGD2000 to WGS 84.
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
read_fude <- function(path = NULL,
                      pref = NULL,
                      year = 2024,
                      census_year = 2020,
                      stringsAsFactors = TRUE,
                      to_wgs84 = TRUE,
                      quiet = FALSE,
                      supplementary = TRUE) {

  if (is.null(path)) {
    if (is.null(pref)) {
      stop("Please specify either `path` or `pref`.")
    } else {
      pref_code <- get_pref_code(pref)
      if (is.null(pref_code) || is.na(pref_code)) {
        stop("Invalid `pref`.")
      }
      path <- get_fude(pref_code, year, census_year)
    }
  }

  if (!grepl(".zip$", path)) {
    stop(path, " is not a ZIP file.")
  }

  exdir <- tempfile()
  on.exit(unlink(exdir, recursive = TRUE))
  utils::unzip(path, exdir = exdir)
  geojson_files <- list.files(exdir, pattern = "\\.json$|\\.geojson$", recursive = TRUE, full.names = TRUE)
  flatgeobuf_files <- list.files(exdir, pattern = "\\.fgb$", recursive = TRUE, full.names = TRUE)

  if (length(geojson_files) > 0) {

    x <- lapply(geojson_files, sf::st_read, quiet = quiet)
    names(x) <- gsub("^.*/|\\.json$|\\.geojson$", "", geojson_files)

  } else {
    if (length(flatgeobuf_files) > 0) {

      x <- lapply(flatgeobuf_files, sf::st_read, quiet = quiet)
      names(x) <- gsub("^.*/|\\.fgb$", "", flatgeobuf_files)

    } else {

      stop("No GeoJSON or FlatGeobuf format file found in ", path, ".")

    }
  }

  if (isTRUE(stringsAsFactors)) {
    x <- purrr::map(x, ~ {
      .x$land_type <- factor(.x$land_type, levels = c(100, 200))
      .x$land_type_jp <- factor(.x$land_type, levels = c(100, 200), labels = c("\u7530", "\u7551"))
      .x
    })
  }

  x <- purrr::map(x, ~ {
    if (!"local_government_cd" %in% names(.x)) {
      .x$local_government_cd <- fude::community_code_table$local_government_cd[
        match(.x$key, fude::community_code_table$KEY)
      ]
    }
    .x
  })

  if (isTRUE(supplementary)) {
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

  # Convert JGD2000 to WGS 84
  if (isTRUE(to_wgs84)) {
    x <- purrr::map(x, ~ sf::st_transform(.x, crs = 4326))
  }

  return(x)
}

get_fude <- function(pref_code, year, census_year) {
  url <- sprintf("https://www.machimura.maff.go.jp/shurakudata/%s/mb/MB0001_%s_%s_%s.zip",
                 census_year, year, census_year, pref_code)

  homepath <- file.path(getwd(), basename(url))

  if (!file.exists(homepath)) {
    utils::download.file(url, homepath)
  }

  return(homepath)
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

.onLoad <- function(libname, pkgname) {
  utils::globalVariables(c(".data"))
  NULL
}
