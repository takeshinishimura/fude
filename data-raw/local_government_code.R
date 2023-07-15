# Local government code/name correspondence table

library(readxl)
library(readr)
library(dplyr)

# Download the latest Excel file containing the local government codes from
# the website of the Ministry of Internal Affairs and Communications.
# https://www.soumu.go.jp/denshijiti/code.html
url <- "https://www.soumu.go.jp/main_content/000892308.xls"
destfile <- file.path("./data-raw", sub(".*/", "", url))

if (!file.exists(destfile)) {
  utils::download.file(url, destfile, quiet = TRUE)
}

# Read the local government codes
lg_code <- readxl::read_excel(destfile, sheet = 1)
names(lg_code) <- sub("\n", "", names(lg_code))

# Read the ordinance-designated city codes
seirei <- readxl::read_excel(destfile, sheet = 2)
seirei <- seirei %>% select(-6)
file.remove(destfile)

# Add codes that have been deleted in recent years (can be found in the
# following list of code revisions).
# https://www.soumu.go.jp/main_content/000875488.xls
seirei_add <- tibble::tribble(
  ~"...1", ~"...2", ~"...3", ~"...4", ~"...5",
  "221317", "\u9759\u5ca1\u770c", "\u6d5c\u677e\u5e02\u4e2d\u533a", "\uff7c\uff7d\uff9e\uff75\uff76\uff79\uff9d", "\uff8a\uff8f\uff8f\uff82\uff7c\uff85\uff76\uff78",
  "221325", "\u9759\u5ca1\u770c", "\u6d5c\u677e\u5e02\u6771\u533a", "\uff7c\uff7d\uff9e\uff75\uff76\uff79\uff9d", "\uff8a\uff8f\uff8f\uff82\uff7c\uff8b\uff76\uff9e\uff7c\uff78",
  "221333", "\u9759\u5ca1\u770c", "\u6d5c\u677e\u5e02\u897f\u533a", "\uff7c\uff7d\uff9e\uff75\uff76\uff79\uff9d", "\uff8a\uff8f\uff8f\uff82\uff7c\uff86\uff7c\uff78",
  "221341", "\u9759\u5ca1\u770c", "\u6d5c\u677e\u5e02\u5357\u533a", "\uff7c\uff7d\uff9e\uff75\uff76\uff79\uff9d", "\uff8a\uff8f\uff8f\uff82\uff7c\uff90\uff85\uff90\uff78",
  "221350", "\u9759\u5ca1\u770c", "\u6d5c\u677e\u5e02\u5317\u533a", "\uff7c\uff7d\uff9e\uff75\uff76\uff79\uff9d", "\uff8a\uff8f\uff8f\uff82\uff7c\uff77\uff80\uff78",
  "221368", "\u9759\u5ca1\u770c", "\u6d5c\u677e\u5e02\u6d5c\u5317\u533a", "\uff7c\uff7d\uff9e\uff75\uff76\uff79\uff9d", "\uff8a\uff8f\uff8f\uff82\uff7c\uff8a\uff8f\uff77\uff80\uff78",
  "221376", "\u9759\u5ca1\u770c", "\u6d5c\u677e\u5e02\u5929\u7adc\u533a", "\uff7c\uff7d\uff9e\uff75\uff76\uff79\uff9d", "\uff8a\uff8f\uff8f\uff82\uff7c\uff83\uff9d\uff98\uff6d\uff73\uff78"
)
names(seirei_add) <- names(seirei)
seirei <- bind_rows(seirei, seirei_add)

# Add designated city codes to the local government code
names(seirei) <- names(lg_code)
lg_code_table <- bind_rows(lg_code, seirei)

# Download the zip file of zip code data (romaji) from the website of Japan
# Post Co.
# https://www.post.japanpost.jp/zipcode/dl/roman-zip.html
url <- "https://www.post.japanpost.jp/zipcode/dl/roman/KEN_ALL_ROME.zip"
destfile <- file.path("./data-raw", sub(".*/", "", url))

if (!file.exists(destfile)) {
  utils::download.file(url, destfile, quiet = TRUE)
}
exdir <- sub(".zip$", "", destfile)
utils::unzip(destfile, exdir = exdir)

ken_all_rome <- read_csv(list.files(exdir,
                                    pattern = "\\.CSV",
                                    full.names = TRUE),
                         col_names = FALSE,
                         locale = readr::locale(encoding = "CP932"))

file.remove(destfile)
unlink(exdir, recursive = TRUE)

kanji <- gsub("(市)(.*区$)", "\\1　\\2",
              lg_code_table$"\u5e02\u533a\u753a\u6751\u540d\uff08\u6f22\u5b57\uff09")
ken_all_rome$X8 <- sub("^.+\u90e1　", "", ken_all_rome$X3)# Gun
ken_all_rome$X9 <- sub("^.+ GUN ", "", ken_all_rome$X6)
ken_all_rome$X8 <- sub("^.+\u5cf6　", "", ken_all_rome$X8)# Shima
ken_all_rome$X9 <- sub("MIYAKEJIMA ", "", ken_all_rome$X9)
ken_all_rome$X9 <- sub("HACHIJOJIMA ", "", ken_all_rome$X9)

romaji <- rep("", length(kanji))
for (i in seq_along(kanji)) {
  romaji[i] <- ken_all_rome$X9[min(which(kanji[i] == ken_all_rome$X8))]
}
# Some Romanization is done manually because the zip code data is not up-to-date
romaji[kanji %in% "\u6d5c\u677e\u5e02\u3000\u4e2d\u592e\u533a"] <- "HAMAMATSU SHI CHUO KU"
romaji[kanji %in% "\u6d5c\u677e\u5e02\u3000\u6d5c\u540d\u533a"] <- "HAMAMATSU SHI HAMANA KU"

lg_code_table$romaji <- gsub(" ", "-", sub(" SHI ", " SHI_", romaji))

names(lg_code_table) <- c("lg_code",
                          "pref_kanji", "city_kanji",
                          "pref_kana", "city_kana",
                          "romaji")

usethis::use_data(lg_code_table, internal = FALSE, overwrite = TRUE)
