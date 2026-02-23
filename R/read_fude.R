#' Read a Fude Polygon ZIP file
#'
#' @description
#' `read_fude()` reads MAFF Fude Polygon data from a ZIP file and returns the
#' layers as a list of [sf::sf()] objects. The ZIP may contain one or more spatial
#' data files such as **GeoJSON** (`.json` or `.geojson`) and **FlatGeobuf**
#' (`.fgb`). The function also works with ZIP files you created, as long as
#' the original filenames are unchanged.
#'
#' @param path
#'   Path to a ZIP file containing one or more supported spatial files
#'   (`.geojson`, `.json`, and `.fgb`).
#' @param pref
#'   Prefecture name or JIS prefecture code.
#' @param year
#'   Year when the Fude Polygon data was created.
#' @param census_year
#'   Year of the Agricultural and Forestry Census.
#' @param supplementary
#'   Logical. If `TRUE`, add supplementary information for each polygon.
#' @param to_wgs84
#'   Logical. If `TRUE`, transform coordinates to WGS 84 (EPSG:4326).
#' @param quiet
#'   If `TRUE`, suppress messages about reading progress.
#'
#' @returns A list of [sf::sf()] objects.
#'
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path)
#'
#' @export
read_fude <- function(
  path = NULL,
  pref = NULL,
  year = 2025,
  census_year = 2020,
  supplementary = FALSE,
  to_wgs84 = TRUE,
  quiet = FALSE
) {
  if (is.null(path)) {
    if (is.null(pref) | pref == "") {
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

  geojson_files <- list.files(
    exdir,
    pattern = "\\.json$|\\.geojson$",
    recursive = TRUE,
    full.names = TRUE
  )
  flatgeobuf_files <- list.files(
    exdir,
    pattern = "\\.fgb$",
    recursive = TRUE,
    full.names = TRUE
  )

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

  validate_fude(x)
  # x <- add_local_government_cd(x)

  if (supplementary) {
    x <- purrr::map(
      x,
      \(d) {
        d$land_type <- factor(d$land_type, levels = c(100, 200))
        d$land_type_jp <- factor(
          d$land_type,
          levels = c(100, 200),
          labels = c("\u7530", "\u7551")
        )
        d
      }
    )

    x <- purrr::map(
      x,
      \(d) {
        # pref_code <- regmatches(i, regexpr("(?<=\\d{4}_)\\d{2}", i, perl = TRUE))
        # crs <- get_plane_rectangular_cs(pref_code)
        # d$area <- sf::st_area(d[[i]] |> sf::st_transform(crs = crs))
        d$area <- sf::st_area(d)
        d$a <- as.numeric(units::set_units(d$area, "a"))

        d
      }
    )
  }

  if (to_wgs84) {
    x <- purrr::map(x, \(d) sf::st_transform(d, crs = 4326))
  }

  return(x)
}

get_fude <- function(
  pref_code,
  year,
  census_year
) {
  url <- sprintf(
    "https://www.machimura.maff.go.jp/shurakudata/%s/mb/MB0001_%s_%s_%s.zip",
    census_year,
    year,
    census_year,
    pref_code
  )

  homepath <- file.path(getwd(), basename(url))

  if (!file.exists(homepath)) {
    utils::download.file(url, homepath)
  }

  return(homepath)
}

modulus11 <- function(data) {
  code5 <- substr(data, start = 1, stop = 5)
  digits <- do.call(rbind, lapply(strsplit(code5, ""), as.numeric))
  weights <- c(6, 5, 4, 3, 2)

  remainder <- (digits %*% weights) %% 11

  check_digit <- ifelse(
    remainder == 0,
    1,
    ifelse(remainder == 1, 0, ifelse(remainder == 10, 1, 11 - remainder))
  )

  return(paste0(code5, check_digit))
}

add_local_government_cd_to_df <- function(data) {
  if (!is.data.frame(data)) {
    return(data)
  }
  if ("local_government_cd" %in% names(data)) {
    return(data)
  }

  key_col <- names(data)[tolower(names(data)) == "key"]

  if (length(key_col) == 0) {
    return(data)
  }

  data$local_government_cd <- modulus11(data[[key_col]])

  return(data)
}

add_local_government_cd <- function(data) {
  if (is.data.frame(data)) {
    return(add_local_government_cd_to_df(data))
  }
  if (is.list(data)) {
    return(lapply(data, add_local_government_cd_to_df))
  }

  return(data)
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

validate_fude <- function(data) {
  if (is.data.frame(data)) {
    if (!"polygon_uuid" %in% names(data)) {
      stop("The data frame must contain a 'polygon_uuid' column.")
    }
  } else if (is.list(data)) {
    if (!"polygon_uuid" %in% names(data[[1]])) {
      stop(
        "The first data frame in the list must contain a 'polygon_uuid' column."
      )
    }
  } else {
    stop("Input must be a Fude Polygon data.")
  }
}

.onLoad <- function(libname, pkgname) {
  utils::globalVariables(c(".data"))
  NULL
}
