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
#' @format A data frame with 47 rows and 2 variables:
#' \describe{
#'   \item{pref_code}{Prefecture codes}
#'   \item{pref_kanji}{Prefecture names in Kanji}
#' }
"pref_code_table"

#' Community code/name correspondence table
#'
#' A dataset containing codes/names of communities in Japan.
#'
#' @format A data frame with 149,511 rows and 13 variables:
#' \describe{
#'   \item{KEY}{Unique community codes}
#'   \item{PREF_NAME}{Prefecture names in Kanji}
#'   \item{PREF_KANA}{Prefecture names in Hiragana}
#'   \item{PREF_ROMAJI}{Prefecture names in Romaji}
#'   \item{CITY_NAME}{City names in Kanji}
#'   \item{CITY_KANA}{City names in Hiragana}
#'   \item{CITY_ROMAJI}{City names in Romaji}
#'   \item{KCITY_NAME}{Former village names in Kanji}
#'   \item{RCOM_NAME}{Community names in Kanji}
#'   \item{RCOM_KANA}{Community names in Hiragana}
#'   \item{RCOM_ROMAJI}{Community names in Romaji}
#'   \item{local_government_cd}{Local government codes}
#'   \item{census_year}{Year of the census from which the data is derived}
#' }
"rcom_code_table"

#' Kcity code/name correspondence table
#'
#' A dataset containing codes/names of kcities in Japan.
#'
#' @format A data frame with 12,110 rows and 10 variables:
#' \describe{
#'   \item{KEY}{Unique kcity codes}
#'   \item{PREF_NAME}{Prefecture names in Kanji}
#'   \item{PREF_KANA}{Prefecture names in Hiragana}
#'   \item{PREF_ROMAJI}{Prefecture names in Romaji}
#'   \item{CITY_NAME}{City names in Kanji}
#'   \item{CITY_KANA}{City names in Hiragana}
#'   \item{CITY_ROMAJI}{City names in Romaji}
#'   \item{KCITY_NAME}{Former village names in Kanji}
#'   \item{local_government_cd}{Local government codes}
#'   \item{census_year}{Year of the census from which the data is derived}
#' }
"kcity_code_table"

#' City code/name correspondence table
#'
#' A dataset containing codes/names of cities in Japan.
#'
#' @format A data frame with 1,905 rows and 9 variables:
#' \describe{
#'   \item{KEY}{Unique kcity codes}
#'   \item{PREF_NAME}{Prefecture names in Kanji}
#'   \item{PREF_KANA}{Prefecture names in Hiragana}
#'   \item{PREF_ROMAJI}{Prefecture names in Romaji}
#'   \item{CITY_NAME}{City names in Kanji}
#'   \item{CITY_KANA}{City names in Hiragana}
#'   \item{CITY_ROMAJI}{City names in Romaji}
#'   \item{local_government_cd}{Local government codes}
#'   \item{census_year}{Year of the census from which the data is derived}
#' }
"city_code_table"
