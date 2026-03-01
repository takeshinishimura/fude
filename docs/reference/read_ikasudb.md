# Read a shuraku Excel file

`read_ikasudb()` reads a shuraku Excel file provided by MAFF.

## Usage

``` r
read_ikasudb(boundary, path, na = c("-", "…"), zero = TRUE)
```

## Arguments

- boundary:

  Agricultural community boundary data as returned by
  [`get_boundary()`](https://takeshinishimura.github.io/fude/reference/get_boundary.md).

- path:

  Path to an `.xlsx` file.

- na:

  Character vector of strings to interpret as missing values. Defaults
  to `c("-", "\u2026")`.

- zero:

  Logical. If `TRUE`, treat masked values (`"x"` and `"X"`) as zero.

## Value

An [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
object.
