# Create a local government code/name correspondence table

library(readxl)
library(stringi)

# Download the latest Excel file containing the local government codes from
# the website of the Ministry of Internal Affairs and Communications.
# https://www.soumu.go.jp/denshijiti/code.html
url <- "https://www.soumu.go.jp/main_content/000875486.xls"
destfile <- file.path("./data-raw", sub(".*/", "", url))

if (!file.exists(destfile)) {
  utils::download.file(url, destfile, quiet = TRUE)
}

# Read the local government codes
lg_code1 <- readxl::read_excel(destfile, sheet = 1)
names(lg_code1) <- sub("\n", "", names(lg_code1))

# Read the ordinance-designated city codes
seirei <- readxl::read_excel(destfile, col_names = FALSE, sheet = 2)

# Add designated city codes to the local government code
new_rows <- seirei[!seirei$...1 %in% lg_code1$"\u56e3\u4f53\u30b3\u30fc\u30c9", ]
new_rows <- tibble::tibble(new_rows[, 1], rep(NA, nrow(new_rows)), new_rows[, 2],
  rep(NA, nrow(new_rows)), new_rows[, 3], .name_repair = "unique")
names(new_rows) <- names(lg_code1)

lg_code <- rbind(lg_code1, new_rows)
kanji <- sub("\uff7c$|\u304f$|\uff81\uff6e\uff73$|\uff7f\uff9d$", "", lg_code$"\u5e02\u533a\u753a\u6751\u540d\uff08\u30ab\u30ca\uff09")
romaji <- stringi::stri_trans_general(kanji, "any-latin")
lg_code$romaji <- paste0(toupper(substring(romaji, 1, 1)), substring(romaji, 2))

file.remove(destfile)

usethis::use_data(lg_code, internal = TRUE, overwrite = TRUE)
