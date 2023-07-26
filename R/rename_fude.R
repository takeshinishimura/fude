#' Rename the Fude Polygon data
#'
#' @description
#' `rename_fude()` renames the 6-digit local government code of the list
#' returned by [read_fude()] to the corresponding Japanese name in order to
#' make the data human-friendly.
#' @param data
#'   List of [sf::sf()] objects.
#' @param suffix
#'   logical. If `FALSE`, suffixes such as "SHI" and "KU" in local government
#'   names are removed.
#' @param romaji
#'   If not `NULL`, rename the local government name in romaji instead of
#'   Japanese. Romanji format is upper case unless specified.
#'   - `"title"`: Title case.
#'   - `"lower"`: Lower case.
#'   - `"upper"`: Upper case.
#' @param quiet
#'   logical. Suppress information about the data to be read.
#' @returns A list of [sf::sf()] objects.
#' @seealso [read_fude()].
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path, quiet = TRUE)
#' d2 <- rename_fude(d)
#' d2 <- rename_fude(d, suffix = FALSE)
#' d2 <- d |> rename_fude(romaji = "upper")
#' @export
rename_fude <- function(data, suffix = TRUE, romaji = NULL, quiet = FALSE) {
  old_names <- names(data)
  nen <- sub("(_.*)", "_", old_names)
  unique_nen <- unique(nen)
  matching_codes <- sub(paste(unique_nen, collapse = "|"), "", old_names)

  new_names <- get_lg_name(matching_codes, suffix, romaji)

  if (suffix == FALSE) {

    new_names <- gsub("-SHI|-KU|-CHO|-MACHI|-SON|-MURA", "", new_names, ignore.case = TRUE)
    new_names <- sub("\u5e02(.*)(\u533a$)", "_\\1", new_names)
    new_names <- sub("(\u5e02|\u533a|\u753a|\u6751)$", "", new_names)

  }

  nochange <- is.na(new_names)
  new_names <- paste0(nen, new_names)
  new_names[nochange] <- old_names[nochange]

  x <- data
  names(x) <- new_names

  if (quiet == FALSE) {
    message(paste(paste0(old_names, " -> ", new_names), collapse = "\n"))
  }

  return(x)
}

get_lg_name <- function(matching_codes, suffix, romaji) {
  matching_idx <- match(matching_codes, fude::lg_code_table$lg_code)

  if (is.null(romaji)) {

    x <- fude::lg_code_table$city_kanji[matching_idx]

  } else {

    x <- fude::lg_code_table$romaji[matching_idx]

    if (romaji == "lower") {

      x <- tolower(x)

    } else {

      if (romaji == "title") {

        unique_string <- "uniquestring"
        tmp <- gsub("-", unique_string, x)
        tmp <- sub("_", " ", tmp)
        x <- tools::toTitleCase(tolower(tmp))
        x <- gsub(unique_string, "-", x)
        x <- sub(" ", "_", x)

      }

    }

  }
  return(x)
}
