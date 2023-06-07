#' Rename the Fude Polygon data
#'
#' @description
#' `rename_fude()` renames the local government code of the list returned by
#' [read_fude()] to the corresponding Japanese name in order to make the data
#' human-friendly.
#' @param data
#'   List of [sf::sf()] objects.
#' @param suffix
#'   Logical. If `FALSE`, suffixes such as "SHI" and "KU" in local government
#'   names are removed.
#' @param romaji
#'   If not `NULL`, rename the local government name in romaji instead of
#'   Japanese. Note that romanization may not be correct. Romanji format is
#'   uppercase unless specified.
#'   - `"title"`: Title case.
#'   - `"lower"`: Lower case.
#'   - `"upper"`: Upper case.
#' @returns A list of [sf::sf()] objects.
#' @seealso [read_fude()].
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path)
#' d2 <- rename_fude(d)
#' d3 <- rename_fude(d, suffix = FALSE)
#' d3 <- d |> rename_fude(suffix = FALSE, romaji = "upper")
#' @export
rename_fude <- function(data, suffix = TRUE, romaji = NULL) {
  old_names <- names(data)
  nen <- sub("(_.*)", "_", old_names)
  unique_nen <- unique(nen)
  matching_cols <- sub(paste(unique_nen, collapse = "|"), "", old_names)
  matching_idx <- match(matching_cols, lg_code$"\u56e3\u4f53\u30b3\u30fc\u30c9")

  if (is.null(romaji)) {

    new_names <- lg_code$"\u5e02\u533a\u753a\u6751\u540d\uff08\u6f22\u5b57\uff09"[matching_idx]

  } else {

    new_names <- lg_code$romaji[matching_idx]

    if (romaji == "lower") {

      new_names <- tolower(new_names)

    } else {

      if (romaji == "title") {

        unique_string <- "uniquestring"
        tmp <- gsub("-", unique_string, new_names)
        tmp <- sub("_", " ", tmp)
        new_names <- tools::toTitleCase(tolower(tmp))
        new_names <- gsub(unique_string, "-", new_names)
        new_names <- sub(" ", "_", new_names)

      }

    }

  }

  if (suffix == FALSE) {

    new_names <- gsub("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", "", new_names, ignore.case = TRUE)
    new_names <- sub("\u5e02(.*)(\u533a$)", "_\\1", new_names)
    new_names <- sub("(\u5e02|\u753a|\u6751)$", "", new_names)

  }

  new_names <- paste0(nen, new_names)
  new_names[grep("NA", new_names)] <- old_names[grep("NA", new_names)]

  x <- data
  names(x) <- new_names

  message(paste(paste0(old_names, " -> ", new_names), collapse = "\n"), "\n")
  return(x)
}
