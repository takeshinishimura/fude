#' Read Fude Polygon data from a ZIP file
#'
#' @description
#' `read_fude()` reads MAFF Fude Polygon data from a ZIP file and returns the
#' layers as a named list of [sf::sf()] objects. If `path` is not supplied, the
#' function downloads the ZIP file for the specified prefecture and year using
#' `pref`, `year`, and `rcom_year`.
#'
#' The ZIP archive may contain one or more supported spatial files in GeoJSON
#' (`.json` or `.geojson`) or FlatGeobuf (`.fgb`) format. The function also
#' works with ZIP files created manually, provided that the original file names
#' are preserved.
#'
#' @param path
#'   Path to a ZIP file containing one or more supported spatial files. If `NULL`,
#'   the file is downloaded automatically from the MAFF website using `pref`,
#'   `year`, and `rcom_year`.
#' @param pref
#'   Prefecture name or prefecture code used when downloading data. Ignored if
#'   `path` is supplied.
#' @param year
#'   The Fude Polygon data year used in the download file name.
#' @param rcom_year
#'   The agricultural community boundary year used in the download file name.
#' @param crs
#'   Coordinate reference system to transform the output layers to. If `NULL`, the
#'   original CRS is kept.
#' @param supplementary
#'   Logical. If `TRUE`, add supplementary columns such as land-use labels and
#'   polygon area.
#' @param quiet
#'   Logical. If `TRUE`, suppress messages during download and reading.
#'
#' @returns
#'   A named list of [sf::sf()] objects.
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
  rcom_year = 2020,
  crs = NULL,
  supplementary = FALSE,
  quiet = FALSE
) {
  if (is.null(path)) {
    if (is.null(pref) || identical(pref, "")) {
      stop("Please specify either `path` or `pref`.")
    }

    pref_code <- get_pref_code(pref)

    if (is.null(pref_code) || is.na(pref_code)) {
      stop("Invalid `pref`.")
    }

    path <- get_fude(pref_code, year, rcom_year, quiet)
  }

  if (!grepl("\\.zip$", path, ignore.case = TRUE)) {
    stop(path, " is not a ZIP file.")
  }

  exdir <- tempfile()
  on.exit(unlink(exdir, recursive = TRUE), add = TRUE)

  utils::unzip(path, exdir = exdir)

  geojson_files <- list.files(
    exdir,
    pattern = "\\.(json|geojson)$",
    recursive = TRUE,
    full.names = TRUE,
    ignore.case = TRUE
  )

  flatgeobuf_files <- list.files(
    exdir,
    pattern = "\\.fgb$",
    recursive = TRUE,
    full.names = TRUE,
    ignore.case = TRUE
  )

  if (length(geojson_files) > 0) {
    x <- lapply(geojson_files, sf::read_sf, quiet = quiet)
    names(x) <- tools::file_path_sans_ext(basename(geojson_files))
  } else if (length(flatgeobuf_files) > 0) {
    x <- lapply(flatgeobuf_files, sf::read_sf, quiet = quiet)
    names(x) <- tools::file_path_sans_ext(basename(flatgeobuf_files))
  } else {
    stop("No GeoJSON or FlatGeobuf file found in ", path, ".")
  }

  validate_fude(x)

  if (isTRUE(supplementary)) {
    x <- lapply(
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

    pref_codes <- unique(
      stats::na.omit(
        substr(
          unlist(
            lapply(x, \(df) {
              if ("key" %in% names(df)) unique(df[["key"]]) else NULL
            }),
            use.names = FALSE
          ),
          1,
          2
        )
      )
    )

    if (length(pref_codes) == 0) {
      pref_codes <- unique(
        stats::na.omit(
          substr(
            unlist(
              lapply(x, \(df) {
                if ("local_government_cd" %in% names(df)) {
                  unique(df[["local_government_cd"]])
                } else {
                  NULL
                }
              }),
              use.names = FALSE
            ),
            1,
            2
          )
        )
      )
    }

    if (length(pref_codes) != 1) {
      stop("Could not determine a unique prefecture code for supplementary area calculation.")
    }

    target_crs <- get_plane_rectangular_cs(pref_codes)

    if (is.null(target_crs) || is.na(target_crs)) {
      stop("Failed to determine plane rectangular CRS from prefecture code.")
    }

    x <- lapply(
      x,
      \(d) {
        d$area <- d |>
          sf::st_transform(crs = target_crs) |>
          sf::st_area()

        d$a <- as.numeric(units::set_units(d$area, "a"))
        d
      }
    )
  }

  if (!is.null(crs)) {
    x <- lapply(x, sf::st_transform, crs = crs)
  }

  return(x)
}

get_fude <- function(
  pref_code,
  year,
  rcom_year,
  quiet
) {
  pref_code <- sprintf("%02d", as.integer(pref_code))

  url <- sprintf(
    "https://www.machimura.maff.go.jp/shurakudata/%s/mb/MB0001_%s_%s_%s.zip",
    rcom_year,
    year,
    rcom_year,
    pref_code
  )

  homepath <- file.path(getwd(), basename(url))

  if (!file.exists(homepath)) {
    utils::download.file(url, homepath, mode = "wb", quiet = quiet)
  }

  return(homepath)
}

modulus11 <- function(data) {
  code5 <- substr(as.character(data), start = 1, stop = 5)

  invalid <- is.na(code5) | !grepl("^\\d{5}$", code5)

  digits <- strsplit(code5, "", fixed = TRUE)
  digits[invalid] <- list(rep(NA_character_, 5))

  digits <- do.call(rbind, lapply(digits, as.numeric))
  weights <- c(6, 5, 4, 3, 2)

  remainder <- as.vector((digits %*% weights) %% 11)

  check_digit <- ifelse(
    is.na(remainder),
    NA_integer_,
    ifelse(
      remainder == 0,
      1,
      ifelse(remainder == 1, 0, ifelse(remainder == 10, 1, 11 - remainder))
    )
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
  cs_mapping <- c(
    "01" = 2454,
    "02" = 2452,
    "03" = 2452,
    "04" = 2452,
    "05" = 2452,
    "06" = 2452,
    "07" = 2451,
    "08" = 2451,
    "09" = 2451,
    "10" = 2451,
    "11" = 2451,
    "12" = 2451,
    "13" = 2451,
    "14" = 2451,
    "15" = 2450,
    "16" = 2449,
    "17" = 2449,
    "18" = 2448,
    "19" = 2450,
    "20" = 2450,
    "21" = 2449,
    "22" = 2450,
    "23" = 2449,
    "24" = 2448,
    "25" = 2448,
    "26" = 2448,
    "27" = 2448,
    "28" = 2447,
    "29" = 2448,
    "30" = 2448,
    "31" = 2447,
    "32" = 2445,
    "33" = 2447,
    "34" = 2445,
    "35" = 2445,
    "36" = 2446,
    "37" = 2446,
    "38" = 2446,
    "39" = 2446,
    "40" = 2444,
    "41" = 2444,
    "42" = 2443,
    "43" = 2444,
    "44" = 2444,
    "45" = 2444,
    "46" = 2444,
    "47" = 2457
  )

  pref_code <- sprintf("%02d", as.integer(pref_code))
  unname(cs_mapping[[pref_code]])
}

validate_fude <- function(data) {
  if (is.data.frame(data)) {
    if (!("polygon_uuid" %in% names(data))) {
      stop("The data frame must contain a `polygon_uuid` column.")
    }
    return(invisible(TRUE))
  }

  if (is.list(data)) {
    if (length(data) == 0) {
      stop("The list must not be empty.")
    }

    ok <- vapply(
      data,
      \(x) is.data.frame(x) && ("polygon_uuid" %in% names(x)),
      logical(1)
    )

    if (!all(ok)) {
      stop("All data frames in the list must contain a `polygon_uuid` column.")
    }

    return(invisible(TRUE))
  }

  stop("Input must be a Fude Polygon data.")
}

.onLoad <- function(libname, pkgname) {
  utils::globalVariables(c(".data"))
  NULL
}
