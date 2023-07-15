#' Local government code/name correspondence table
#'
#' A dataset containing codes/names of local governments in Japan.
#'
#' @format A data frame with 1,992 rows and 6 variables:
#' \describe{
#'   \item{lg_code}{Local government codes}
#'   \item{pref_kanji}{Prefecture names written in kanji}
#'   \item{city_kanji}{Local government names written in kanji}
#'   \item{pref_kana}{Prefecture names written in katakana}
#'   \item{city_kana}{Local government names written in katakana}
#'   \item{romaji}{Local government names written in romaji}
#' }
"lg_code_table"

#' Prefecture code/name correspondence table
#'
#' A dataset containing codes/names of prefectures in Japan.
#'
#' @format A data frame with 47 rows and 2 variables:
#' \describe{
#'   \item{pref_code}{Prefecture codes}
#'   \item{pref_kanji}{Prefecture names written in kanji}
#' }
"pref_table"
