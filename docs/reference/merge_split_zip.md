# Merge Split ZIP Files of MAFF Fude Polygon Data

`merge_split_zip()` combines split ZIP files of Fude Polygon data
provided by MAFF into a single ZIP archive.

## Usage

``` r
merge_split_zip(path, output_dir = getwd(), quiet = FALSE)
```

## Arguments

- path:

  Path to the first part (`.zip.001`) of a split ZIP archive.

- output_dir:

  Directory in which to save the merged ZIP file. Defaults to the
  current working directory.

- quiet:

  Logical. If `TRUE`, suppress progress messages.

## Value

Invisibly returns a character string containing the path to the merged
ZIP file.

## Details

All parts of the split ZIP archive (e.g., `.zip.001`, `.zip.002`, and
`.zip.003`) must be downloaded to the same directory before running this
function.

The files are concatenated in numerical order to reconstruct the
original ZIP archive. The resulting ZIP file is not extracted. The
original split files are preserved.

## Examples

``` r
if (FALSE) { # \dontrun{
merge_fude_zip("MB0001_2026_2025_38.zip.001")
} # }
```
