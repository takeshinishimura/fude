#' Get agricultural community boundary data
#'
#' @description
#' `get_boundary()` downloads and reads one or more MAFF agricultural community
#' boundary datasets and returns them as a named list of [sf::sf()] objects.
#' The target prefectures are determined from `data`.
#'
#' @param data
#'   Either a Fude Polygon data object returned by [read_fude()], or a prefecture
#'   code or Japanese prefecture name.
#' @param boundary_data_year
#'   The year of the boundary dataset.
#' @param rcom_year
#'   The agricultural community reference year used in the MAFF file name.
#' @param boundary_type
#'   Integer specifying the boundary level to read: `1` for agricultural
#'   community, `2` for former municipality, and `3` for municipality.
#' @param path
#'   Path to a directory containing boundary ZIP files. If `NULL`, ZIP files are
#'   downloaded automatically.
#' @param suffix
#'   Logical. If `FALSE`, suffixes are removed from romaji municipality names,
#'   such as `"-shi"` and `"-ku"`.
#' @param crs
#'   Coordinate reference system to transform the output data to. If `NULL`, the
#'   source CRS is kept.
#' @param encoding
#'   Character encoding of the source shapefile attributes, such as `"CP932"`.
#' @param quiet
#'   Logical. If `TRUE`, suppress messages during download and reading.
#'
#' @returns
#'   A named list of [sf::sf()] objects.
#'
#' @examplesIf interactive()
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path)
#' b <- get_boundary(d)
#'
#' @export
get_boundary <- function(
  data,
  boundary_data_year = 2020,
  rcom_year = 2020,
  boundary_type = 1,
  path = NULL,
  suffix = FALSE,
  crs = NULL,
  encoding = "CP932",
  quiet = FALSE
) {
  pref_codes <- fude_to_pref_code(data)

  if (length(pref_codes) == 0) {
    stop("No prefecture code could be determined from `data`.")
  }

  x <- lapply(
    pref_codes,
    \(d) {
      read_boundary(
        get_pref_code(d),
        boundary_data_year,
        rcom_year,
        boundary_type,
        path,
        suffix,
        crs,
        encoding,
        quiet
      )
    }
  ) |>
    stats::setNames(
      sprintf(
        "MA000%s_%s_%s_%s",
        boundary_type,
        boundary_data_year,
        rcom_year,
        vapply(pref_codes, get_pref_code, character(1))
      )
    )

  return(x)
}

read_boundary <- function(
  pref_code,
  boundary_data_year,
  rcom_year,
  boundary_type,
  path,
  suffix,
  crs,
  encoding,
  quiet
) {
  pref_code <- get_pref_code(pref_code)

  url <- sprintf(
    "https://www.machimura.maff.go.jp/shurakudata/%s/ma/MA000%s_%s_%s_%s.zip",
    rcom_year,
    boundary_type,
    boundary_data_year,
    rcom_year,
    pref_code
  )

  zipfile <- tempfile(fileext = ".zip")
  exdir <- tempfile()
  dir.create(exdir)

  on.exit(unlink(c(zipfile, exdir), recursive = TRUE, force = TRUE), add = TRUE)

  homepath <- file.path(getwd(), basename(url))

  if (is.null(path)) {
    if (!file.exists(homepath)) {
      utils::download.file(url, homepath, mode = "wb", quiet = quiet)
    }

    ok <- file.copy(homepath, zipfile, overwrite = TRUE)
    if (!ok) {
      stop("Failed to copy downloaded ZIP file: ", homepath)
    }
  } else {
    source_zip <- file.path(path, basename(url))

    if (!file.exists(source_zip)) {
      stop("ZIP file not found: ", source_zip)
    }

    ok <- file.copy(source_zip, zipfile, overwrite = TRUE)
    if (!ok) {
      stop("Failed to copy ZIP file: ", source_zip)
    }
  }

  utils::unzip(zipfile, exdir = exdir)

  shp_files <- list.files(
    exdir,
    pattern = "\\.shp$",
    recursive = TRUE,
    full.names = TRUE,
    ignore.case = TRUE
  )

  if (length(shp_files) != 1) {
    stop(
      if (length(shp_files) > 1) {
        "Multiple shapefiles found."
      } else {
        "No shapefile found in the ZIP archive."
      }
    )
  }

  x <- sf::read_sf(
    shp_files,
    quiet = quiet,
    options = paste0("ENCODING=", encoding)
  ) |>
    dplyr::rename_with(tolower) |>
    (\(d) {
      if (boundary_type == 2) {
        d |>
          dplyr::mutate(
            rcom = "000",
            rcom_name = NA_character_,
            rcom_kana = NA_character_,
            rcom_romaji = NA_character_
          )
      } else if (boundary_type == 3) {
        d |>
          dplyr::mutate(
            kcity = "00",
            rcom = "000",
            kcity_name = NA_character_,
            rcom_name = NA_character_,
            rcom_kana = NA_character_,
            rcom_romaji = NA_character_
          )
      } else {
        d
      }
    })() |>
    (\(d) {
      if (boundary_type == 1 && !("rcom_kana" %in% names(d))) {
        d |>
          dplyr::left_join(
            fude::rcom_code_table |>
              dplyr::select(
                .data$key,
                .data$pref_kana,
                .data$city_kana,
                .data$rcom_kana,
                .data$pref_romaji,
                .data$city_romaji,
                .data$rcom_romaji
              ),
            by = "key"
          )
      } else if (boundary_type == 1) {
        d |>
          dplyr::left_join(
            fude::rcom_code_table |>
              dplyr::select(
                .data$key,
                .data$pref_kana,
                .data$city_kana,
                .data$pref_romaji,
                .data$city_romaji,
                .data$rcom_romaji
              ),
            by = "key"
          )
      } else if (boundary_type == 2) {
        d |>
          dplyr::left_join(
            fude::kcity_code_table |>
              dplyr::select(
                .data$key,
                .data$pref_kana,
                .data$city_kana,
                .data$pref_romaji,
                .data$city_romaji
              ),
            by = "key"
          )
      } else if (boundary_type == 3) {
        d |>
          dplyr::left_join(
            fude::city_code_table |>
              dplyr::select(
                .data$key,
                .data$pref_kana,
                .data$city_kana,
                .data$pref_romaji,
                .data$city_romaji
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
        )),
        \(col) factor(col, levels = unique(stats::na.omit(col)))
      ),
    ) |>
    dplyr::select(
      .data$key, .data$pref, .data$city, .data$kcity, .data$rcom,
      .data$pref_name, .data$city_name, .data$kcity_name, .data$rcom_name,
      .data$pref_kana, .data$city_kana, .data$rcom_kana,
      .data$pref_romaji, .data$city_romaji, .data$rcom_romaji,
      dplyr::any_of("hinintei"),
      .data$geometry
    ) |>
    dplyr::mutate(
      boundary_data_year = boundary_data_year,
      rcom_year = rcom_year
    )

  if (isFALSE(suffix) && "city_romaji" %in% names(x)) {
    levels(x$city_romaji) <- remove_romaji_suffix(levels(x$city_romaji))
  }

  if (!is.null(crs) && sf::st_crs(x)$epsg != crs) {
    x <- sf::st_transform(x, crs = crs)
  }

  return(x)
}

fude_to_lg_code <- function(data) {
  if (is.character(data)) {
    return(data)
  }

  if (is.data.frame(data)) {
    if (!("local_government_cd" %in% names(data))) {
      return(character())
    }
    return(data[["local_government_cd"]])
  }

  if (is.list(data)) {
    x <- unlist(
      lapply(
        data,
        \(d) {
          if (!is.data.frame(d)) {
            return(NULL)
          }
          if (!("local_government_cd" %in% names(d))) {
            return(NULL)
          }
          d[["local_government_cd"]]
        }
      ),
      use.names = FALSE
    )

    return(x)
  }

  return(character())
}

fude_to_pref_code <- function(data) {
  data <- add_local_government_cd(data)
  local_government_cd <- fude_to_lg_code(data)

  x <- local_government_cd |>
    substr(start = 1, stop = 2) |>
    stats::na.omit() |>
    unique()

  x <- x[nzchar(x)]

  return(x)
}

get_pref_code <- function(data) {
  data_chr <- as.character(data)

  if (grepl("^\\d+$", data_chr)) {
    data_chr <- sprintf("%02d", as.integer(data_chr))
  }

  if (data_chr %in% fude::pref_code_table$pref_code) {
    x <- data_chr
  } else if (data_chr %in% fude::pref_code_table$pref_kanji) {
    x <- fude::pref_code_table$pref_code[
      match(data_chr, fude::pref_code_table$pref_kanji)
    ]
  } else if (
    data_chr %in%
      sub("(\u90FD|\u5E9C|\u770C)$", "", fude::pref_code_table$pref_kanji)
  ) {
    x <- fude::pref_code_table$pref_code[
      match(
        data_chr,
        sub("(\u90FD|\u5E9C|\u770C)$", "", fude::pref_code_table$pref_kanji)
      )
    ]
  } else {
    stop("Invalid input. Please enter a valid prefecture name or code.")
  }

  return(x)
}

remove_romaji_suffix <- function(x) {
  tolower(
    gsub(
      "-SHI|-KU|-CHO|-MACHI|-SON|-MURA",
      "",
      x,
      ignore.case = TRUE
    )
  )
}
