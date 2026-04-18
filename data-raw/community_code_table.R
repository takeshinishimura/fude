# Community code/name correspondence table

library(dplyr)
library(stringi)
library(purrr)
library(sf)

read_boundary <- function(boundary_type, boundary_data_year, rcom_year, pref_code, path = "~/ma") {
  url <- sprintf(
    "https://www.machimura.maff.go.jp/shurakudata/%s/ma/MA000%s_%s_%s_%s.zip",
    rcom_year,
    boundary_type,
    boundary_data_year,
    rcom_year,
    pref_code
  )

  path <- path.expand(path)
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  zipfile <- file.path(path, basename(url))

  if (!file.exists(zipfile)) {
    utils::download.file(url, zipfile)
  }

  exdir <- tempfile()
  dir.create(exdir)

  shp_files <- utils::unzip(zipfile, exdir = exdir)
  shp_files <- shp_files[grepl("\\.shp$", shp_files, ignore.case = TRUE)]

  on.exit(unlink(exdir, recursive = TRUE), add = TRUE)

  if (length(shp_files) != 1) {
    stop(
      ifelse(
        length(shp_files) > 1,
        "Multiple shapefiles found.",
        "No shapefile found in the ZIP archive."
      )
    )
  }

  sf::st_read(
    shp_files[1],
    quiet = FALSE,
    options = if (rcom_year %in% c(2010, 2015, 2020)) {
      "ENCODING=CP932"
    } else {
      "ENCODING=UTF-8"
    }
  )
}

process_city_kana <- function(pref_name, city_name, column) {
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
    x <- tolower(x)
    x <- gsub("^(.)", "\\U\\1", x, perl = TRUE)
    x <- gsub("_(.)", "_\\U\\1", x, perl = TRUE)
  }

  return(x)
}

pref_code_table <- tibble::tibble(
  pref = sprintf("%02d", 1:47),
  pref_name = c(
    "\u5317\u6d77\u9053",
    "\u9752\u68ee\u770c", "\u5ca9\u624b\u770c", "\u5bae\u57ce\u770c",
    "\u79cb\u7530\u770c", "\u5c71\u5f62\u770c", "\u798f\u5cf6\u770c",
    "\u8328\u57ce\u770c", "\u6804\u6728\u770c", "\u7fa4\u99ac\u770c",
    "\u57fc\u7389\u770c", "\u5343\u8449\u770c", "\u6771\u4eac\u90fd",
    "\u795e\u5948\u5ddd\u770c",
    "\u65b0\u6f5f\u770c", "\u5bcc\u5c71\u770c",
    "\u77f3\u5ddd\u770c", "\u798f\u4e95\u770c",
    "\u5c71\u68a8\u770c", "\u9577\u91ce\u770c",
    "\u5c90\u961c\u770c", "\u9759\u5ca1\u770c",
    "\u611b\u77e5\u770c", "\u4e09\u91cd\u770c",
    "\u6ecb\u8cc0\u770c", "\u4eac\u90fd\u5e9c", "\u5927\u962a\u5e9c",
    "\u5175\u5eab\u770c", "\u5948\u826f\u770c", "\u548c\u6b4c\u5c71\u770c",
    "\u9ce5\u53d6\u770c", "\u5cf6\u6839\u770c",
    "\u5ca9\u5c71\u770c", "\u5e83\u5cf6\u770c",
    "\u5c71\u53e3\u770c",
    "\u5fb3\u5cf6\u770c", "\u9999\u5ddd\u770c",
    "\u611b\u5a9b\u770c", "\u9ad8\u77e5\u770c",
    "\u798f\u5ca1\u770c", "\u4f50\u8cc0\u770c", "\u9577\u5d0e\u770c",
    "\u718a\u672c\u770c", "\u5927\u5206\u770c",
    "\u5bae\u5d0e\u770c", "\u9e7f\u5150\u5cf6\u770c",
    "\u6c96\u7e04\u770c"
  ),
  pref_kana = c(
    "\u307b\u3063\u304b\u3044\u3069\u3046",
    "\u3042\u304a\u3082\u308a\u3051\u3093", "\u3044\u308f\u3066\u3051\u3093", "\u307f\u3084\u304e\u3051\u3093",
    "\u3042\u304d\u305f\u3051\u3093", "\u3084\u307e\u304c\u305f\u3051\u3093", "\u3075\u304f\u3057\u307e\u3051\u3093",
    "\u3044\u3070\u3089\u304d\u3051\u3093", "\u3068\u3061\u304e\u3051\u3093", "\u3050\u3093\u307e\u3051\u3093",
    "\u3055\u3044\u305f\u307e\u3051\u3093", "\u3061\u3070\u3051\u3093", "\u3068\u3046\u304d\u3087\u3046\u3068",
    "\u304b\u306a\u304c\u308f\u3051\u3093",
    "\u306b\u3044\u304c\u305f\u3051\u3093", "\u3068\u3084\u307e\u3051\u3093",
    "\u3044\u3057\u304b\u308f\u3051\u3093", "\u3075\u304f\u3044\u3051\u3093",
    "\u3084\u307e\u306a\u3057\u3051\u3093", "\u306a\u304c\u306e\u3051\u3093",
    "\u304e\u3075\u3051\u3093", "\u3057\u305a\u304a\u304b\u3051\u3093",
    "\u3042\u3044\u3061\u3051\u3093", "\u307f\u3048\u3051\u3093",
    "\u3057\u304c\u3051\u3093", "\u304d\u3087\u3046\u3068\u3075", "\u304a\u304a\u3055\u304b\u3075",
    "\u3072\u3087\u3046\u3054\u3051\u3093", "\u306a\u3089\u3051\u3093", "\u308f\u304b\u3084\u307e\u3051\u3093",
    "\u3068\u3063\u3068\u308a\u3051\u3093", "\u3057\u307e\u306d\u3051\u3093",
    "\u304a\u304b\u3084\u307e\u3051\u3093", "\u3072\u308d\u3057\u307e\u3051\u3093",
    "\u3084\u307e\u3050\u3061\u3051\u3093",
    "\u3068\u304f\u3057\u307e\u3051\u3093", "\u304b\u304c\u308f\u3051\u3093",
    "\u3048\u3072\u3081\u3051\u3093", "\u3053\u3046\u3061\u3051\u3093",
    "\u3075\u304f\u304a\u304b\u3051\u3093", "\u3055\u304c\u3051\u3093", "\u306a\u304c\u3055\u304d\u3051\u3093",
    "\u304f\u307e\u3082\u3068\u3051\u3093", "\u304a\u304a\u3044\u305f\u3051\u3093",
    "\u307f\u3084\u3056\u304d\u3051\u3093", "\u304b\u3054\u3057\u307e\u3051\u3093",
    "\u304a\u304d\u306a\u308f\u3051\u3093"
  ),
  pref_romaji = c(
    "Hokkaido",
    "Aomori", "Iwate", "Miyagi",
    "Akita", "Yamagata", "Fukushima",
    "Ibaraki", "Tochigi", "Gunma",
    "Saitama", "Chiba", "Tokyo",
    "Kanagawa",
    "Niigata", "Toyama",
    "Ishikawa", "Fukui",
    "Yamanashi", "Nagano",
    "Gifu", "Shizuoka",
    "Aichi", "Mie",
    "Shiga", "Kyoto", "Osaka",
    "Hyogo", "Nara", "Wakayama",
    "Tottori", "Shimane",
    "Okayama", "Hiroshima",
    "Yamaguchi",
    "Tokushima", "Kagawa",
    "Ehime", "Kochi",
    "Fukuoka", "Saga", "Nagasaki",
    "Kumamoto", "Oita",
    "Miyazaki", "Kagoshima",
    "Okinawa"
  )
)

usethis::use_data(pref_code_table, internal = FALSE, overwrite = TRUE)

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

years <- c(2020, 2015, 2010)
rcom <- setNames(vector("list", length(years)), as.character(years))

for (rcom_year in years){
  x <- setNames(vector("list", 47), sprintf("%02d", 1:47))
  boundary_data_year <- rcom_year

  for (pref_code in sprintf("%02d", 1:47)) {
    x[[pref_code]] <- read_boundary(
      boundary_type = 1,
      boundary_data_year = boundary_data_year,
      rcom_year = rcom_year,
      pref_code = pref_code
    ) |>
      sf::st_drop_geometry() |>
      dplyr::rename_with(tolower) |>
      dplyr::select(-pref_name) |>
      (\(col) {
       if ("rcom_kana" %in% names(col)) {
          col
        } else {
          dplyr::mutate(col, rcom_kana = NA_character_)
        }
      })() |>
      dplyr::left_join(pref_code_table, by = "pref") |>
      dplyr::rowwise() |>
      dplyr::mutate(
        city_kana = process_city_kana(pref_name, city_name, "city_kana"),
        city_romaji = process_city_kana(pref_name, city_name, "romaji")
#       local_government_cd = process_city_kana(pref_name, city_name, "lg_code")
      ) |>
      dplyr::ungroup() |>
      dplyr::mutate(
        rcom_romaji = rcom_kana |>
          stringi::stri_trans_general("any-latin") |>
          stringi::stri_trans_totitle(),
        local_government_cd = modulus11(key)
      ) |>
      dplyr::select(
        key,
        pref_name, pref_kana, pref_romaji,
        city_name, city_kana, city_romaji,
        kcity_name,
        rcom_name, rcom_kana, rcom_romaji,
        local_government_cd
      )
  }

  rcom[[as.character(rcom_year)]] <- dplyr::bind_rows(x)
}

rcom_code_table <- purrr::list_rbind(rcom, names_to = "rcom_year") |>
  dplyr::mutate(rcom_year = as.integer(rcom_year)) |>
  dplyr::arrange(dplyr::desc(rcom_year)) |>
  dplyr::distinct(
    dplyr::across(-c(rcom_year, rcom_name, rcom_kana, rcom_romaji)),
    .keep_all = TRUE
  )

usethis::use_data(rcom_code_table, internal = FALSE, overwrite = TRUE)

kcity <- setNames(vector("list", length(years)), as.character(years))

for (rcom_year in years){
  x <- setNames(vector("list", 47), sprintf("%02d", 1:47))
  boundary_data_year <- rcom_year

  for (pref_code in sprintf("%02d", 1:47)) {
    x[[pref_code]] <- read_boundary(
      boundary_type = 2,
      boundary_data_year = boundary_data_year,
      rcom_year = rcom_year,
      pref_code = pref_code
    ) |>
      sf::st_drop_geometry() |>
      dplyr::rename_with(tolower) |>
      dplyr::select(-pref_name) |>
      dplyr::left_join(pref_code_table, by = "pref") |>
      dplyr::rowwise() |>
      dplyr::mutate(
        city_kana = process_city_kana(pref_name, city_name, "city_kana"),
        city_romaji = process_city_kana(pref_name, city_name, "romaji")
#       local_government_cd = process_city_kana(pref_name, city_name, "lg_code")
      ) |>
      dplyr::ungroup() |>
      dplyr::mutate(
        local_government_cd = modulus11(key)
      ) |>
      dplyr::select(
        key,
        pref_name, pref_kana, pref_romaji,
        city_name, city_kana, city_romaji,
        kcity_name,
        local_government_cd
      )
  }

  kcity[[as.character(rcom_year)]] <- dplyr::bind_rows(x)
}

kcity_code_table <- purrr::list_rbind(kcity, names_to = "rcom_year") |>
  dplyr::mutate(rcom_year = as.integer(rcom_year)) |>
  dplyr::arrange(dplyr::desc(rcom_year)) |>
  dplyr::distinct(
    dplyr::across(-rcom_year),
    .keep_all = TRUE
  )

usethis::use_data(kcity_code_table, internal = FALSE, overwrite = TRUE)

city <- setNames(vector("list", length(years)), as.character(years))

for (rcom_year in years){
  x <- setNames(vector("list", 47), sprintf("%02d", 1:47))
  boundary_data_year <- rcom_year

  for (pref_code in sprintf("%02d", 1:47)) {
    x[[pref_code]] <- read_boundary(
      boundary_type = 3,
      boundary_data_year = boundary_data_year,
      rcom_year = rcom_year,
      pref_code = pref_code
    ) |>
      sf::st_drop_geometry() |>
      dplyr::rename_with(tolower) |>
      dplyr::select(-pref_name) |>
      dplyr::left_join(pref_code_table, by = "pref") |>
      dplyr::rowwise() |>
      dplyr::mutate(
        city_kana = process_city_kana(pref_name, city_name, "city_kana"),
        city_romaji = process_city_kana(pref_name, city_name, "romaji")
#       local_government_cd = process_city_kana(pref_name, city_name, "lg_code")
      ) |>
      dplyr::ungroup() |>
        dplyr::mutate(
          local_government_cd = modulus11(key)
        ) |>
      dplyr::select(
        key,
        pref_name, pref_kana, pref_romaji,
        city_name, city_kana, city_romaji,
        local_government_cd
      )
  }

  city[[as.character(rcom_year)]] <- dplyr::bind_rows(x)
}

city_code_table <- purrr::list_rbind(city, names_to = "rcom_year") |>
  dplyr::mutate(rcom_year = as.integer(rcom_year)) |>
  dplyr::arrange(dplyr::desc(rcom_year)) |>
  dplyr::distinct(
    dplyr::across(-rcom_year),
    .keep_all = TRUE
  )

usethis::use_data(city_code_table, internal = FALSE, overwrite = TRUE)
