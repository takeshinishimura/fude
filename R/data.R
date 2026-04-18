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
#'   \item{pref}{Prefecture codes}
#'   \item{pref_name}{Prefecture names in Kanji}
#'   \item{pref_kana}{Prefecture names in Hiragana}
#'   \item{pref_romaji}{Prefecture names in Romaji}
#' }
"pref_code_table"

#' Community code/name correspondence table
#'
#' A dataset containing codes/names of communities in Japan.
#'
#' @format A data frame with 149,511 rows and 13 variables:
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
#'   \item{rcom_year}{Agricultural community reference year}
#' }
"rcom_code_table"

#' Kcity code/name correspondence table
#'
#' A dataset containing codes/names of kcities in Japan.
#'
#' @format A data frame with 12,110 rows and 10 variables:
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
#'   \item{rcom_year}{Agricultural community reference year}
#' }
"kcity_code_table"

#' City code/name correspondence table
#'
#' A dataset containing codes/names of cities in Japan.
#'
#' @format A data frame with 1,905 rows and 9 variables:
#' \describe{
#'   \item{key}{Unique city codes}
#'   \item{pref_name}{Prefecture names in Kanji}
#'   \item{pref_kana}{Prefecture names in Hiragana}
#'   \item{pref_romaji}{Prefecture names in Romaji}
#'   \item{city_name}{City names in Kanji}
#'   \item{city_kana}{City names in Hiragana}
#'   \item{city_romaji}{City names in Romaji}
#'   \item{local_government_cd}{Local government codes}
#'   \item{rcom_year}{Agricultural community reference year}
#' }
"city_code_table"
