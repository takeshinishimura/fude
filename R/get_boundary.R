#' Get the agricultural community boundary data
#'
#' @description
#' `get_boundary()` downloads and reads one or more agricultural community
#' boundary data provided by the MAFF.
#'
#' @param data
#'   List of one or more MAFF agricultural community boundary data or one or more strings representing prefecture
#'   codes.
#' @param year
#'   Year when the agricultural community boundary data was created.
#' @param census_year
#'   Year of the Agricultural and Forestry Census.
#' @param boundary_type
#'   Type of boundary data. 1 = agricultural community, 2 = former city , or 3 = city.
#' @param path
#'   Path to the ZIP file containing the agricultural community boundary data;
#'   use a local ZIP file instead of going looking for a ZIP file. Specify a
#'   directory containing one or more ZIP files, not the ZIP file itself.
#' @param to_wgs84
#'   Logical. If `TRUE`, transform coordinates to WGS 84 (EPSG:4326).
#' @param encoding
#'   CP932
#' @param quiet
#'   If `TRUE`, suppress messages about reading progress.
#'
#' @returns A list of [sf::sf()] objects.
#'
#' @examplesIf interactive()
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path)
#' b <- get_boundary(d)
#'
#' @export
get_boundary <- function(
  data,
  year = 2020,
  census_year = 2020,
  boundary_type = 1,
  path = NULL,
  to_wgs84 = TRUE,
  encoding = "CP932",
  quiet = FALSE
) {
  pref_codes <- fude_to_pref_code(data)

  x <- lapply(
    pref_codes,
    \(d) {
      pref_code <- get_pref_code(d)
      read_boundary(pref_code, year, census_year, boundary_type, path, to_wgs84, encoding, quiet)
    }
  )

  names(x) <- sprintf(
    "MA000%s_%s_%s_%s",
    boundary_type,
    year,
    census_year,
    sapply(pref_codes, get_pref_code)
  )

  return(x)
}

read_boundary <- function(
  pref_code,
  year,
  census_year,
  boundary_type,
  path,
  to_wgs84,
  encoding,
  quiet
) {
  url <- sprintf(
    "https://www.machimura.maff.go.jp/shurakudata/%s/ma/MA000%s_%s_%s_%s.zip",
    census_year,
    boundary_type,
    year,
    census_year,
    pref_code
  )

  zipfile <- tempfile(fileext = ".zip")
  homepath <- file.path(getwd(), basename(url))

  if (is.null(path)) {
    if (!file.exists(homepath)) {
      utils::download.file(url, homepath)
    }
    file.copy(homepath, zipfile)
  } else {
    file.copy(file.path(path, basename(url)), zipfile)
  }

  exdir <- tempdir()
  on.exit({
    unlink(zipfile)
    unlink(shp_files)
  })
  utils::unzip(zipfile, exdir = exdir)

  shp_files <- list.files(
    exdir,
    pattern = "\\.shp$",
    recursive = TRUE,
    full.names = TRUE
  )

  if (length(shp_files) != 1) {
    stop(ifelse(
      length(shp_files) > 1,
      "Multiple shapefiles found.",
      "No shapefile found in the ZIP archive."
    ))
  }

  x <- sf::st_read(
    shp_files,
    quiet = quiet,
    options = paste0("ENCODING=", encoding)
  ) |>
    dplyr::rename_with(tolower) |>
    (\(d) {
      if (boundary_type == 1) {
        dplyr::left_join(
          d,
          fude::rcom_code_table |>
            dplyr::select(
              .data$key,
              .data$pref_kana,
              .data$pref_romaji,
              .data$city_kana,
              .data$city_romaji,
              .data$rcom_romaji
            ),
          by = "key"
        )
      } else if (boundary_type == 2) {
        dplyr::left_join(
          d,
          fude::kcity_code_table |>
            dplyr::select(
              .data$key,
              .data$pref_kana,
              .data$pref_romaji,
              .data$city_kana,
            ),
          by = "key"
        )
      } else if (boundary_type == 3) {
        dplyr::left_join(
          d,
          fude::city_code_table |>
            dplyr::select(
              .data$key,
              .data$pref_kana,
              .data$pref_romaji,
              .data$city_kana,
            ),
          by = "key"
        )
      } else {
        d
      }
    })() |>
      dplyr::mutate(
        dplyr::across(
          dplyr::any_of(c(
            "pref_name", "pref_kana", "pref_romaji",
            "city_name", "city_kana", "city_romaji",
            "kcity_name",
            "rcom_name", "rcom_kana", "rcom_romaji"
          )
        ),
        \(col) factor(col, levels = unique(stats::na.omit(col)))
    ))|>
    dplyr::mutate(
      boundary_edit_year = year,
      boundary_census_year = census_year
    )

  if (sf::st_crs(x)$epsg != 4326 && isTRUE(to_wgs84)) {
    x <- sf::st_transform(x, crs = 4326)
  }

  return(x)
  }

fude_to_lg_code <- function(data) {
  if (is.character(data)) {
    return(data)
  }

  if (is.data.frame(data)) {
    if (!"local_government_cd" %in% names(data)) {
      return(character())
    }
    return(data[["local_government_cd"]])
  }

  if (is.list(data)) {
    cd <- unlist(
      lapply(
        data,
        \(d) {
          if (!is.data.frame(d)) {
            return(NULL)
          }
          if (!"local_government_cd" %in% names(d)) {
            return(NULL)
          }
          d[["local_government_cd"]]
        }
      ),
      use.names = FALSE
    )

    return(cd)
  }

  return(character())
}

fude_to_pref_code <- function(data) {
  data <- add_local_government_cd(data)
  local_government_cd <- fude_to_lg_code(data)

  x <- unique(substr(local_government_cd, start = 1, stop = 2))

  return(x)
}

get_pref_code <- function(data) {
  if (data %in% fude::pref_code_table$pref_code) {
    x <- data
  } else if (data %in% fude::pref_code_table$pref_kanji == data) {
    x <- fude::pref_code_table$pref_code[
      fude::pref_code_table$pref_kanji == data
    ]
  } else if (
    data %in%
      sub("(\u90FD|\u5E9C|\u770C)$", "", fude::pref_code_table$pref_kanji)
  ) {
    x <- fude::pref_code_table$pref_code[grepl(
      data,
      sub("(\u90FD|\u5E9C|\u770C)$", "", fude::pref_code_table$pref_kanji)
    )][1]
  } else {
    stop("Invalid input. Please enter a valid prefecture name or code.")
  }

  return(x)
}
