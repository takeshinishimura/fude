#' Local government code/name correspondence table
#'
#' A dataset containing codes/names of local governments in Japan.
#'
#' @format A data frame with 1,992 rows and 6 variables:
#' \describe{
#'   \item{lg_code}{Local government codes}
#'   \item{pref_kanji}{Prefecture names in Kanji}
#'   \item{city_kanji}{Local government names in Kanji}
#'   \item{pref_kana}{Prefecture names in Katakana}
#'   \item{city_kana}{Local government names in Katakana}
#'   \item{romaji}{Local government names in Romaji}
#' }
"lg_code_table"

#' Prefecture code/name correspondence table
#'
#' A dataset containing codes/names of prefectures in Japan.
#'
#' @format A data frame with 47 rows and 4 variables:
#' \describe{
#'   \item{pref}{Prefecture codes}
#'   \item{pref_name}{Prefecture names in Kanji}
#'   \item{pref_kana}{Prefecture names in Hiragana}
#'   \item{pref_romaji}{Prefecture names in Romaji}
#' }
"pref_code_table"

#' Community ID/name correspondence table
#'
#' A dataset containing codes/names of communities in Japan.
#'
#' @format A data frame with 154,069 rows and 13 variables:
#' \describe{
#'   \item{key}{Unique community codes}
#'   \item{pref_name}{Prefecture names in Kanji}
#'   \item{pref_kana}{Prefecture names in Hiragana}
#'   \item{pref_romaji}{Prefecture names in Romaji}
#'   \item{city_name}{City names in Kanji}
#'   \item{city_kana}{City names in Hiragana}
#'   \item{city_romaji}{City names in Romaji}
#'   \item{kcity_name}{Former village names in Kanji}
#'   \item{rcom_name}{Community names in Kanji}
#'   \item{rcom_kana}{Community names in Hiragana}
#'   \item{rcom_romaji}{Community names in Romaji}
#'   \item{local_government_cd}{Local government codes}
#'   \item{id}{ID}
#' }
"rcom_id_table"

#' Community year/ID correspondence table
#'
#' A dataset containing year/ID of communities in Japan.
#'
#' @format A data frame with 448,296 rows and 2 variables:
#' \describe{
#'   \item{rcom_year}{Agricultural community reference year}
#'   \item{id}{Reference ID for rcom_id_table}
#' }
"rcom_year_id"

#' Kcity ID/name correspondence table
#'
#' A dataset containing codes/names of kcities in Japan.
#'
#' @format A data frame with 12,642 rows and 10 variables:
#' \describe{
#'   \item{key}{Unique kcity codes}
#'   \item{pref_name}{Prefecture names in Kanji}
#'   \item{pref_kana}{Prefecture names in Hiragana}
#'   \item{pref_romaji}{Prefecture names in Romaji}
#'   \item{city_name}{City names in Kanji}
#'   \item{city_kana}{City names in Hiragana}
#'   \item{city_romaji}{City names in Romaji}
#'   \item{kcity_name}{Former city names in Kanji}
#'   \item{local_government_cd}{Local government codes}
#'   \item{id}{ID}
#' }
"kcity_id_table"

#' Community year/Kcity ID correspondence table
#'
#' A dataset containing year/ID of communities in Japan.
#'
#' @format A data frame with 36,375 rows and 2 variables:
#' \describe{
#'   \item{rcom_year}{Agricultural community reference year}
#'   \item{id}{Reference ID for kcity_id_table}
#' }
"kcity_year_id"

#' City ID/name correspondence table
#'
#' A dataset containing codes/names of cities in Japan.
#'
#' @format A data frame with 1,970 rows and 9 variables:
#' \describe{
#'   \item{key}{Unique city codes}
#'   \item{pref_name}{Prefecture names in Kanji}
#'   \item{pref_kana}{Prefecture names in Hiragana}
#'   \item{pref_romaji}{Prefecture names in Romaji}
#'   \item{city_name}{City names in Kanji}
#'   \item{city_kana}{City names in Hiragana}
#'   \item{city_romaji}{City names in Romaji}
#'   \item{local_government_cd}{Local government codes}
#'   \item{id}{ID}
#' }
"city_id_table"

#' Community year/city ID correspondence table
#'
#' A dataset containing year/ID of communities in Japan.
#'
#' @format A data frame with 5,753 rows and 2 variables:
#' \describe{
#'   \item{rcom_year}{Agricultural community reference year}
#'   \item{id}{Reference ID for city_id_table}
#' }
"city_year_id"
