# Get agricultural community boundary data

`get_boundary()` downloads and reads one or more MAFF agricultural
community boundary datasets and returns them as a named list of
[`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) objects.
The target prefectures are determined from `data`.

## Usage

``` r
get_boundary(
  data,
  boundary_data_year = 2020,
  rcom_year = 2020,
  boundary_type = 1,
  path = NULL,
  suffix = FALSE,
  crs = NULL,
  encoding = "CP932",
  quiet = FALSE
)
```

## Arguments

- data:

  Either a Fude Polygon data object returned by
  [`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md),
  or a prefecture code or Japanese prefecture name.

- boundary_data_year:

  The year of the boundary dataset.

- rcom_year:

  The agricultural community reference year used in the MAFF file name.

- boundary_type:

  Integer specifying the boundary level to read: `1` for agricultural
  community, `2` for former municipality, and `3` for municipality.

- path:

  Path to a directory containing boundary ZIP files. If `NULL`, ZIP
  files are downloaded automatically.

- suffix:

  Logical. If `FALSE`, suffixes are removed from romaji municipality
  names, such as `"-shi"` and `"-ku"`.

- crs:

  Coordinate reference system to transform the output data to. If
  `NULL`, the source CRS is kept.

- encoding:

  Character encoding of the source shapefile attributes, such as
  `"CP932"`.

- quiet:

  Logical. If `TRUE`, suppress messages during download and reading.

## Value

A named list of
[`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) objects.

## Examples

``` r
if (FALSE) { # interactive()
path <- system.file("extdata", "castle.zip", package = "fude")
d <- read_fude(path)
b <- get_boundary(d)
}
```
