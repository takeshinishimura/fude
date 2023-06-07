# Create a local government code/name correspondence table

library(readxl)
library(readr)
library(dplyr)

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

file.remove(destfile)

# Add designated city codes to the local government code
new_rows <- seirei[!seirei$...1 %in% lg_code1$"\u56e3\u4f53\u30b3\u30fc\u30c9", ]
new_rows <- tibble::tibble(new_rows[, 1],
                           rep(NA, nrow(new_rows)),
                           new_rows[, 2],
                           rep(NA, nrow(new_rows)),
                           new_rows[, 3],
                           .name_repair = "unique")
names(new_rows) <- names(lg_code1)

lg_code <- rbind(lg_code1, new_rows)

# Download the zip file of zip code data (romaji) from the website of Japan
# Post Co.
# https://www.post.japanpost.jp/zipcode/dl/roman-zip.html
url <- "https://www.post.japanpost.jp/zipcode/dl/roman/ken_all_rome.zip"
destfile <- file.path("./data-raw", sub(".*/", "", url))

if (!file.exists(destfile)) {
  utils::download.file(url, destfile, quiet = TRUE)
}
exdir <- sub(".zip$", "", destfile)
utils::unzip(destfile, exdir = exdir)

ken_all_rome <- read_csv(list.files(exdir,
                                    pattern = "\\.csv",
                                    full.names = TRUE),
                         col_names = FALSE,
                         locale = readr::locale(encoding = "CP932"))

file.remove(destfile)
unlink(exdir, recursive = TRUE)

kanji <- gsub("(市)(.*区$)", "\\1　\\2",
              lg_code$"\u5e02\u533a\u753a\u6751\u540d\uff08\u6f22\u5b57\uff09")
ken_all_rome$X8 <- gsub("^.+\u90e1　", "", ken_all_rome$X3)
ken_all_rome$X9 <- gsub("^.+ GUN ", "", ken_all_rome$X6)

romaji <- rep("", length(kanji))
for (i in seq_along(kanji)) {
  romaji[i] <- ken_all_rome$X9[min(which(kanji[i] == ken_all_rome$X8))]
}
# Some Romanization is done manually because the zip code data is not up-to-date
romaji[kanji %in% "\u6d5c\u677e\u5e02\u3000\u4e2d\u592e\u533a"] <- "HAMAMATSU SHI CHUO KU"
romaji[kanji %in% "\u6d5c\u677e\u5e02\u3000\u6d5c\u540d\u533a"] <- "HAMAMATSU SHI HAMANA KU"

lg_code$romaji <- gsub(" ", "-", sub(" SHI ", " SHI_", romaji))

usethis::use_data(lg_code, internal = TRUE, overwrite = TRUE)
