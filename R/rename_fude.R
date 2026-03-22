#' Rename Fude Polygon data
#'
#' @description
#' `rename_fude()` renames the elements of a Fude Polygon data object returned
#' by [read_fude()] by replacing local government codes in the element names
#' with corresponding municipality names, making the object easier to read.
#'
#' @param data
#'   A Fude Polygon data object returned by [read_fude()].
#' @param suffix
#'   Logical. If `FALSE`, municipality suffixes are removed from renamed element
#'   names. For example, Japanese suffixes such as `"市"`, `"区"`, `"町"`, and
#'   `"村"` are removed, and romaji suffixes such as `"-shi"` and `"-ku"` are
#'   also removed when `romaji` is used.
#' @param romaji
#'   Character scalar or `NULL`. If `NULL`, Japanese municipality names are used.
#'   Otherwise, municipality names are converted to romaji. Supported values are:
#'   `"upper"` for upper case, `"title"` for title case, and `"lower"` for lower
#'   case.
#' @param quiet
#'   Logical. If `FALSE`, print the mapping from old names to new names.
#'
#' @returns
#'   A Fude Polygon data object with renamed elements.
#'
#' @seealso [read_fude()]
#'
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path, quiet = FALSE)
#' d2 <- rename_fude(d)
#' d2 <- rename_fude(d, suffix = FALSE)
#' d2 <- rename_fude(d, romaji = "upper")
#'
#' @export
rename_fude <- function(
  data,
  suffix = TRUE,
  romaji = NULL,
  quiet = TRUE
) {
  validate_fude(data)

  old_names <- names(data)

  if (is.null(old_names)) {
    stop("`data` must have names.")
  }

  nen <- sub("^([^_]*_).*$", "\\1", old_names)
  matching_codes <- sub("^[^_]*_", "", old_names)

  new_names <- get_lg_name(matching_codes, romaji)

  if (isFALSE(suffix)) {
    new_names <- remove_romaji_suffix(new_names)
    new_names <- sub("\u5e02(.*)(\u533a$)", "_\\1", new_names)
    new_names <- sub("(\u5e02|\u533a|\u753a|\u6751)$", "", new_names)
  }

  nochange <- is.na(new_names)
  new_names <- paste0(nen, new_names)
  new_names[nochange] <- old_names[nochange]

  names(data) <- new_names

  if (isFALSE(quiet)) {
    message(paste(paste0(old_names, " -> ", new_names), collapse = "\n"))
  }

  return(data)
}

get_lg_name <- function(
  matching_codes,
  romaji = NULL
) {
  matching_idx <- match(matching_codes, fude::lg_code_table$lg_code)

  if (is.null(romaji)) {
    x <- fude::lg_code_table$city_kanji[matching_idx]
  } else {
    x <- fude::lg_code_table$romaji[matching_idx]

    if (identical(romaji, "lower")) {
      x <- tolower(x)
    } else if (identical(romaji, "title")) {
      unique_string <- "uniquestring"
      tmp <- gsub("-", unique_string, x)
      tmp <- gsub("_", " ", tmp)
      x <- tools::toTitleCase(tolower(tmp))
      x <- gsub(unique_string, "-", x)
      x <- gsub(" ", "_", x)
    }
  }

  return(x)
}
