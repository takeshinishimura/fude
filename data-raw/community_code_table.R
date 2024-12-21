# Community code/name correspondence table

library(dplyr)
library(stringi)
library(sf)

year <- 2020
census_year <- 2020

read_boundary <- function(pref_code) {
  url <- sprintf("https://www.machimura.maff.go.jp/shurakudata/%s/ma/MA0001_%s_%s_%s.zip",
                 census_year, year, census_year, pref_code)

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

  value <- temp |>
    dplyr::pull({{ column }})

  if (column %in% c("pref_kana", "city_kana")) {
    value <- value |>
      stringi::stri_trans_general("Halfwidth-Fullwidth") |>
      stringi::stri_trans_general("Katakana-Hiragana")
  } else if (column == "romaji") {
    value <- value |>
      stringi::stri_trans_totitle()
  }

  return(value)
}

community_code_table <- NULL

pref_romaji_table <- tibble::tibble(
  PREF_KANA = c(
    "ほっかいどう", "あおもりけん", "いわてけん", "みやぎけん", "あきたけん",
    "やまがたけん", "ふくしまけん", "いばらきけん", "とちぎけん", "ぐんまけん",
    "さいたまけん", "ちばけん", "とうきょうと", "かながわけん", "にいがたけん",
    "とやまけん", "いしかわけん", "ふくいけん", "やまなしけん", "ながのけん",
    "ぎふけん", "しずおかけん", "あいちけん", "みえけん", "しがけん",
    "きょうとふ", "おおさかふ", "ひょうごけん", "ならけん", "わかやまけん",
    "とっとりけん", "しまねけん", "おかやまけん", "ひろしまけん", "やまぐちけん",
    "とくしまけん", "かがわけん", "えひめけん", "こうちけん", "ふくおかけん",
    "さがけん", "ながさきけん", "くまもとけん", "おおいたけん", "みやざきけん",
    "かごしまけん", "おきなわけん"
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

for (pref_code in sprintf("%02d", 1:47)) {
  new_pref <- read_boundary(pref_code) |>
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

  community_code_table <- rbind(community_code_table, new_pref)
}

usethis::use_data(community_code_table, internal = FALSE, overwrite = TRUE)
