#' Itemize the structure of Fude Polygon data
#'
#' @description
#' `ls_fude()` lists the year and the local government names (or codes) in
#' order to understand what is included in the list returned by [read_fude()].
#'
#' @param data
#'   List of [sf::sf()] objects.
#' @returns A list.
#' @seealso [read_fude()].
#'
#' @examples
#' path <- system.file("extdata", "castle.zip", package = "fude")
#' d <- read_fude(path)
#' ls_fude(d)
#'
#' @export
ls_fude <- function(data) {
  nen <- unique(sub("(_.*)", "", names(data)))
  x <- list()

  for (i in nen) {
    x[[i]] <- sub(paste0(i, "_"), "", names(data)[grep(i, names(data))])
  }

  return(x)
}
