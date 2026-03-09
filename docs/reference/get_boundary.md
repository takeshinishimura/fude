# Get the agricultural community boundary data

`get_boundary()` downloads and reads one or more agricultural community
boundary data provided by the MAFF.

## Usage

``` r
get_boundary(
  data,
  boundary_data_year = 2020,
  rcom_year = 2020,
  boundary_type = 1,
  path = NULL,
  suffix = FALSE,
  to_wgs84 = FALSE,
  encoding = "CP932",
  quiet = FALSE
)
```

## Arguments

- data:

  Either Fude Polygon data as returned by
  [`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md),
  or a two-digit prefecture code.

- boundary_data_year:

  Year when the agricultural community boundary data were created.

- rcom_year:

  Year of the agricultural community boundary data.

- boundary_type:

  The type of boundary data: `1` = agricultural community, `2` = former
  municipality, `3` = municipality.

- path:

  Path to the ZIP file containing the agricultural community boundary
  data; use a local ZIP file instead of going looking for a ZIP file.
  Specify a directory containing one or more ZIP files, not the ZIP file
  itself.

- suffix:

  Logical. If `FALSE`, suffixes such as "-SHI" and "-KU" in local
  government names are removed.

- to_wgs84:

  Logical. If `TRUE`, transform coordinates to WGS 84 (EPSG:4326).

- encoding:

  Character encoding of the source files (e.g., `"CP932"`).

- quiet:

  Logical. If `TRUE`, suppress messages about reading progress.

## Value

A list of [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
objects.

## Examples

``` r
if (FALSE) { # interactive()
path <- system.file("extdata", "castle.zip", package = "fude")
d <- read_fude(path)
b <- get_boundary(d)
}
```
