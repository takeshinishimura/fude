#' Merge Split ZIP Files of MAFF Fude Polygon Data
#'
#' @description
#' `merge_split_zip()` combines split ZIP files of Fude Polygon data
#' provided by MAFF into a single ZIP archive.
#'
#' @details
#' All parts of the split ZIP archive (e.g., `.zip.001`, `.zip.002`,
#' and `.zip.003`) must be downloaded to the same directory before
#' running this function.
#'
#' The files are concatenated in numerical order to reconstruct
#' the original ZIP archive. The resulting ZIP file is not extracted.
#' The original split files are preserved.
#'
#' @param path
#'   Path to the first part (`.zip.001`) of a split ZIP archive.
#' @param output_dir
#'   Directory in which to save the merged ZIP file.
#'   Defaults to the current working directory.
#' @param quiet
#'   Logical. If `TRUE`, suppress progress messages.
#'
#' @returns
#'   Invisibly returns a character string containing the path
#'   to the merged ZIP file.
#'
#' @examples
#' \dontrun{
#' merge_fude_zip("MB0001_2026_2025_38.zip.001")
#' }
#'
#' @export
merge_split_zip <- function(
  path,
  output_dir = getwd(),
  quiet = FALSE
) {
  # Validate arguments
  if (
    !is.character(path) || length(path) != 1L ||
    is.na(path) || !endsWith(path, ".zip.001")
  ) {
    stop("`path` must be a path to a '.zip.001' file.", call. = FALSE)
  }

  if (
    !file.exists(path) || dir.exists(path)
  ) {
    stop("File does not exist: ", path, call. = FALSE)
  }

  if (
    !is.character(output_dir) || length(output_dir) != 1L ||
    is.na(output_dir) || !dir.exists(output_dir)
  ) {
    stop("`output_dir` must be an existing directory.", call. = FALSE)
  }

  if (
    !is.logical(quiet) || length(quiet) != 1L ||
    is.na(quiet)
  ) {
    stop("`quiet` must be TRUE or FALSE.", call. = FALSE)
  }

  # Identify split ZIP files
  base_path <- sub("\\.001$", "", path)
  input_dir <- dirname(base_path)

  parts <- list.files(
    input_dir,
    pattern = "\\.zip\\.[0-9]{3}$",
    full.names = TRUE
  )

  parts <- parts[
    startsWith(basename(parts), paste0(basename(base_path), "."))
  ]

  parts <- sort(parts)

  # Check for missing parts
  if (
    length(parts) == 0L ||
    !identical(
      basename(parts),
      sprintf("%s.%03d", basename(base_path), seq_along(parts))
    )
  ) {
    stop("Split ZIP files are missing or not consecutive.", call. = FALSE)
  }

  # Check output path
  output_file <- file.path(
    output_dir,
    basename(base_path)
  )

  if (file.exists(output_file)) {
    stop("Output file already exists: ", output_file, call. = FALSE)
  }

  # Create a temporary file
  temp_file <- tempfile(
    pattern = "split_zip_",
    tmpdir = output_dir
  )

  on.exit(unlink(temp_file), add = TRUE)

  if (!file.create(temp_file)) {
    stop("Failed to create a temporary file.", call. = FALSE)
  }

  # Merge files
  for (part in parts) {
    if (!quiet) {
      message("Merging: ", basename(part))
    }

    if (!isTRUE(file.append(temp_file, part))) {
      stop("Failed to append file: ", part, call. = FALSE)
    }
  }

  # Save merged ZIP file
  if (!file.rename(temp_file, output_file)) {
    stop("Failed to save merged ZIP file.", call. = FALSE)
  }

  if (!quiet) {
    message("Merge complete: ", output_file)
  }

  invisible(output_file)
}
