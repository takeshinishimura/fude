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

# Add codes that have been deleted in recent years (can be found in the
# following list of code revisions).
# https://www.soumu.go.jp/main_content/000875488.xls
seirei_add <- tibble::tribble(
  ~"...1", ~"...2", ~"...3",
  "221317", "\u6d5c\u677e\u5e02\u4e2d\u533a", "\u306f\u307e\u307e\u3064\u3057\u306a\u304b\u304f",
  "221325", "\u6d5c\u677e\u5e02\u6771\u533a", "\u306f\u307e\u307e\u3064\u3057\u3072\u304c\u3057\u304f",
  "221333", "\u6d5c\u677e\u5e02\u897f\u533a", "\u306f\u307e\u307e\u3064\u3057\u306b\u3057\u304f",
  "221341", "\u6d5c\u677e\u5e02\u5357\u533a", "\u306f\u307e\u307e\u3064\u3057\u307f\u306a\u307f\u304f",
  "221350", "\u6d5c\u677e\u5e02\u5317\u533a", "\u306f\u307e\u307e\u3064\u3057\u304d\u305f\u304f",
  "221368", "\u6d5c\u677e\u5e02\u6d5c\u5317\u533a", "\u306f\u307e\u307e\u3064\u3057\u306f\u307e\u304d\u305f\u304f",
  "221376", "\u6d5c\u677e\u5e02\u5929\u7adc\u533a", "\u306f\u307e\u307e\u3064\u3057\u3066\u3093\u308a\u3085\u3046\u304f"
)
seirei <- bind_rows(seirei, seirei_add)

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
ken_all_rome$X8 <- sub("^.+\u90e1　", "", ken_all_rome$X3)
ken_all_rome$X9 <- sub("^.+ GUN ", "", ken_all_rome$X6)
ken_all_rome$X8 <- sub("^.+\u5cf6　", "", ken_all_rome$X8)
ken_all_rome$X9 <- sub("MIYAKEJIMA ", "", ken_all_rome$X9)
ken_all_rome$X9 <- sub("HACHIJOJIMA ", "", ken_all_rome$X9)

romaji <- rep("", length(kanji))
for (i in seq_along(kanji)) {
  romaji[i] <- ken_all_rome$X9[min(which(kanji[i] == ken_all_rome$X8))]
}
# Some Romanization is done manually because the zip code data is not up-to-date
romaji[kanji %in% "\u6d5c\u677e\u5e02\u3000\u4e2d\u592e\u533a"] <- "HAMAMATSU SHI CHUO KU"
romaji[kanji %in% "\u6d5c\u677e\u5e02\u3000\u6d5c\u540d\u533a"] <- "HAMAMATSU SHI HAMANA KU"

lg_code$romaji <- gsub(" ", "-", sub(" SHI ", " SHI_", romaji))

usethis::use_data(lg_code, internal = TRUE, overwrite = TRUE)
