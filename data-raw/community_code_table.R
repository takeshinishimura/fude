# Community code/name correspondence table

library(dplyr)
library(stringi)
library(sf)

year <- 2020
census_year <- 2020

read_boundary <- function(pref_code, boundary_type) {
  url <- sprintf(
    "https://www.machimura.maff.go.jp/shurakudata/%s/ma/MA000%s_%s_%s_%s.zip",
    census_year,
    boundary_type,
    year,
    census_year,
    pref_code
  )

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
    stop(
      ifelse(
        length(shp_files) > 1,
        "Multiple shapefiles found.",
        "No shapefile found in the ZIP archive."
      )
    )
  }

  x <- sf::st_read(shp_files, quiet = FALSE, options = "ENCODING=CP932")

  return(x)
}

process_kana <- function(pref_name, city_name, column) {
  temp <- fude::lg_code_table |>
    dplyr::filter(pref_kanji == pref_name, city_kanji == city_name)

  if (nrow(temp) == 0) {
    cleaned_city_name <- stringr::str_remove(city_name, "（.*?）")
    temp <- fude::lg_code_table |>
      dplyr::filter(pref_kanji == pref_name) |>
      dplyr::filter(grepl(cleaned_city_name, city_kanji))
  }

  # 北海道泊村 14036, 16969
  # 静岡県浜松市天竜区 221406（2024年1月1日から）, 221376（2023年12月31日まで）
  temp <- temp[1, , drop = FALSE]

  x <- temp |>
    dplyr::pull({{ column }})

  if (column %in% c("pref_kana", "city_kana")) {
    x <- x |>
      stringi::stri_trans_general("Halfwidth-Fullwidth") |>
      stringi::stri_trans_general("Katakana-Hiragana")
  } else if (column == "romaji") {
    x <- x |>
      stringi::stri_trans_totitle()
  }

  return(x)
}

pref_romaji_table <- tibble::tibble(
  PREF_KANA = c(
    "\u307b\u3063\u304b\u3044\u3069\u3046",
    "\u3042\u304a\u3082\u308a\u3051\u3093",
    "\u3044\u308f\u3066\u3051\u3093",
    "\u307f\u3084\u304e\u3051\u3093",
    "\u3042\u304d\u305f\u3051\u3093",
    "\u3084\u307e\u304c\u305f\u3051\u3093",
    "\u3075\u304f\u3057\u307e\u3051\u3093",
    "\u3044\u3070\u3089\u304d\u3051\u3093",
    "\u3068\u3061\u304e\u3051\u3093",
    "\u3050\u3093\u307e\u3051\u3093",
    "\u3055\u3044\u305f\u307e\u3051\u3093",
    "\u3061\u3070\u3051\u3093",
    "\u3068\u3046\u304d\u3087\u3046\u3068",
    "\u304b\u306a\u304c\u308f\u3051\u3093",
    "\u306b\u3044\u304c\u305f\u3051\u3093",
    "\u3068\u3084\u307e\u3051\u3093",
    "\u3044\u3057\u304b\u308f\u3051\u3093",
    "\u3075\u304f\u3044\u3051\u3093",
    "\u3084\u307e\u306a\u3057\u3051\u3093",
    "\u306a\u304c\u306e\u3051\u3093",
    "\u304e\u3075\u3051\u3093",
    "\u3057\u305a\u304a\u304b\u3051\u3093",
    "\u3042\u3044\u3061\u3051\u3093",
    "\u307f\u3048\u3051\u3093",
    "\u3057\u304c\u3051\u3093",
    "\u304d\u3087\u3046\u3068\u3075",
    "\u304a\u304a\u3055\u304b\u3075",
    "\u3072\u3087\u3046\u3054\u3051\u3093",
    "\u306a\u3089\u3051\u3093",
    "\u308f\u304b\u3084\u307e\u3051\u3093",
    "\u3068\u3063\u3068\u308a\u3051\u3093",
    "\u3057\u307e\u306d\u3051\u3093",
    "\u304a\u304b\u3084\u307e\u3051\u3093",
    "\u3072\u308d\u3057\u307e\u3051\u3093",
    "\u3084\u307e\u3050\u3061\u3051\u3093",
    "\u3068\u304f\u3057\u307e\u3051\u3093",
    "\u304b\u304c\u308f\u3051\u3093",
    "\u3048\u3072\u3081\u3051\u3093",
    "\u3053\u3046\u3061\u3051\u3093",
    "\u3075\u304f\u304a\u304b\u3051\u3093",
    "\u3055\u304c\u3051\u3093",
    "\u306a\u304c\u3055\u304d\u3051\u3093",
    "\u304f\u307e\u3082\u3068\u3051\u3093",
    "\u304a\u304a\u3044\u305f\u3051\u3093",
    "\u307f\u3084\u3056\u304d\u3051\u3093",
    "\u304b\u3054\u3057\u307e\u3051\u3093",
    "\u304a\u304d\u306a\u308f\u3051\u3093"
  ),
  PREF_ROMAJI = c(
    "Hokkaido", "Aomori", "Iwate", "Miyagi", "Akita",
    "Yamagata", "Fukushima", "Ibaraki", "Tochigi", "Gunma",
    "Saitama", "Chiba", "Tokyo", "Kanagawa", "Niigata",
    "Toyama", "Ishikawa", "Fukui", "Yamanashi", "Nagano",
    "Gifu", "Shizuoka", "Aichi", "Mie", "Shiga",
    "Kyoto", "Osaka", "Hyogo", "Nara", "Wakayama",
    "Tottori", "Shimane", "Okayama", "Hiroshima", "Yamaguchi",
    "Tokushima", "Kagawa", "Ehime", "Kochi", "Fukuoka",
    "Saga", "Nagasaki", "Kumamoto", "Oita", "Miyazaki",
    "Kagoshima", "Okinawa"
  )
)

x <- setNames(vector("list", 47), sprintf("%02d", 1:47))

for (pref_code in sprintf("%02d", 1:47)) {
  x[[pref_code]] <- read_boundary(pref_code, boundary_type = 1) |>
    sf::st_drop_geometry() |>
    dplyr::rowwise() |>
    dplyr::mutate(
      PREF_KANA = process_kana(PREF_NAME, CITY_NAME, "pref_kana"),
      CITY_KANA = process_kana(PREF_NAME, CITY_NAME, "city_kana"),
      CITY_ROMAJI = process_kana(PREF_NAME, CITY_NAME, "romaji"),
      local_government_cd = process_kana(PREF_NAME, CITY_NAME, "lg_code"),
    ) |>
    dplyr::ungroup() |>
    dplyr::left_join(pref_romaji_table, by = "PREF_KANA") |>
    dplyr::mutate(
      RCOM_ROMAJI = .data$RCOM_KANA |>
        stringi::stri_trans_general("any-latin") |>
        stringi::stri_trans_totitle(),
      census_year = census_year
    ) |>
    dplyr::select(
      KEY, PREF_NAME, PREF_KANA, PREF_ROMAJI, CITY_NAME, CITY_KANA, CITY_ROMAJI,
      KCITY_NAME, RCOM_NAME, RCOM_KANA, RCOM_ROMAJI,
      local_government_cd, census_year
    )
}

rcom_code_table <- dplyr::bind_rows(x)

usethis::use_data(rcom_code_table, internal = FALSE, overwrite = TRUE)

x <- setNames(vector("list", 47), sprintf("%02d", 1:47))

for (pref_code in sprintf("%02d", 1:47)) {
  x[[pref_code]] <- read_boundary(pref_code, boundary_type = 2) |>
    sf::st_drop_geometry() |>
    dplyr::rowwise() |>
    dplyr::mutate(
      PREF_KANA = process_kana(PREF_NAME, CITY_NAME, "pref_kana"),
      CITY_KANA = process_kana(PREF_NAME, CITY_NAME, "city_kana"),
      CITY_ROMAJI = process_kana(PREF_NAME, CITY_NAME, "romaji"),
      local_government_cd = process_kana(PREF_NAME, CITY_NAME, "lg_code"),
    ) |>
    dplyr::ungroup() |>
    dplyr::left_join(pref_romaji_table, by = "PREF_KANA") |>
    dplyr::mutate(
      census_year = census_year
    ) |>
    dplyr::select(
      KEY, PREF_NAME, PREF_KANA, PREF_ROMAJI, CITY_NAME, CITY_KANA, CITY_ROMAJI,
      KCITY_NAME,
      local_government_cd, census_year
    )
}

kcity_code_table <- dplyr::bind_rows(x)

usethis::use_data(kcity_code_table, internal = FALSE, overwrite = TRUE)

x <- setNames(vector("list", 47), sprintf("%02d", 1:47))

for (pref_code in sprintf("%02d", 1:47)) {
  x[[pref_code]] <- read_boundary(pref_code, boundary_type = 3) |>
    sf::st_drop_geometry() |>
    dplyr::rowwise() |>
    dplyr::mutate(
      PREF_KANA = process_kana(PREF_NAME, CITY_NAME, "pref_kana"),
      CITY_KANA = process_kana(PREF_NAME, CITY_NAME, "city_kana"),
      CITY_ROMAJI = process_kana(PREF_NAME, CITY_NAME, "romaji"),
      local_government_cd = process_kana(PREF_NAME, CITY_NAME, "lg_code"),
    ) |>
    dplyr::ungroup() |>
    dplyr::left_join(pref_romaji_table, by = "PREF_KANA") |>
    dplyr::mutate(
      census_year = census_year
    ) |>
    dplyr::select(
      KEY, PREF_NAME, PREF_KANA, PREF_ROMAJI, CITY_NAME, CITY_KANA, CITY_ROMAJI,
      local_government_cd, census_year
    )
}

city_code_table <- dplyr::bind_rows(x)

usethis::use_data(city_code_table, internal = FALSE, overwrite = TRUE)
