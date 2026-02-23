# Get the agricultural community boundary data

`get_boundary()` downloads and reads one or more agricultural community
boundary data provided by the MAFF.

## Usage

``` r
get_boundary(
  data,
  year = 2020,
  census_year = 2020,
  path = NULL,
  to_wgs84 = TRUE,
  quiet = FALSE
)
```

## Arguments

- data:

  List of [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
  objects or one or more strings representing prefecture codes.

- year:

  Year when the agricultural community boundary data was created.

- census_year:

  Year of the Agricultural and Forestry Census.

- path:

  Path to the ZIP file containing the agricultural community boundary
  data; use a local ZIP file instead of going looking for a ZIP file.
  Specify a directory containing one or more ZIP files, not the ZIP file
  itself.

- to_wgs84:

  Logical. If `TRUE`, transform coordinates to WGS 84 (EPSG:4326).

- quiet:

  If `TRUE`, suppress messages about reading progress.

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
