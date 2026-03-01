#' Get the agricultural community boundary data
#'
#' @description
#' `get_boundary()` downloads and reads one or more agricultural community
#' boundary data provided by the MAFF.
#'
#' @param data
#'   Either Fude Polygon data as returned by [read_fude()], or a two-digit
#'   prefecture code.
#' @param boundary_data_year
#'   Year when the agricultural community boundary data were created.
#' @param rcom_year
#'   Year of the agricultural community boundary data.
#' @param boundary_type
#'   The type of boundary data:
#'   `1` = agricultural community,
#'   `2` = former municipality,
#'   `3` = municipality.
#' @param path
#'   Path to the ZIP file containing the agricultural community boundary data;
#'   use a local ZIP file instead of going looking for a ZIP file. Specify a
#'   directory containing one or more ZIP files, not the ZIP file itself.
#' @param suffix
#'   Logical. If `FALSE`, suffixes such as "-SHI" and "-KU" in local government
#'   names are removed.
#' @param to_wgs84
#'   Logical. If `TRUE`, transform coordinates to WGS 84 (EPSG:4326).
#' @param encoding
#'   Character encoding of the source files (e.g., `"CP932"`).
#' @param quiet
#'   Logical. If `TRUE`, suppress messages about reading progress.
#'
#' @returns
#'   A list of [sf::sf()] objects.
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
  to_wgs84 = TRUE,
  encoding = "CP932",
  quiet = FALSE
) {
  pref_codes <- fude_to_pref_code(data)

  x <- lapply(
    pref_codes,
    \(d) {
      pref_code <- get_pref_code(d)
      read_boundary(
        pref_code,
        boundary_data_year,
        rcom_year,
        boundary_type,
        path,
        suffix,
        to_wgs84,
        encoding,
        quiet
      )
    }
  )

  names(x) <- sprintf(
    "MA000%s_%s_%s_%s",
    boundary_type,
    boundary_data_year,
    rcom_year,
    sapply(pref_codes, get_pref_code)
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
  to_wgs84,
  encoding,
  quiet
) {
  url <- sprintf(
    "https://www.machimura.maff.go.jp/shurakudata/%s/ma/MA000%s_%s_%s_%s.zip",
    rcom_year,
    boundary_type,
    boundary_data_year,
    rcom_year,
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
      if (boundary_type == 1) {
        d |>
        dplyr::left_join(
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
        d |>
        dplyr::left_join(
          fude::kcity_code_table |>
            dplyr::select(
              .data$key,
              .data$pref_kana,
              .data$pref_romaji,
              .data$city_kana,
              .data$city_romaji,
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
              .data$pref_romaji,
              .data$city_kana,
              .data$city_romaji,
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
      )
    ) |>
    dplyr::select(
      .data$key, .data$pref, .data$city, .data$kcity, .data$rcom,
      .data$pref_name, .data$city_name, .data$kcity_name, .data$rcom_name,
      .data$pref_kana, .data$city_kana, .data$rcom_kana,
      .data$pref_romaji, .data$city_romaji, .data$rcom_romaji,
      .data$hinintei,
      .data$geometry
    ) |>
    dplyr::mutate(
      boundary_data_year = boundary_data_year,
      rcom_year = rcom_year
    )

  if (isFALSE(suffix)) {
    levels(x$city_romaji) <- remove_romaji_suffix(levels(x$city_romaji))
  }

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
