# Read a shuraku excel file

`read_ikasudb()` reads a shuraku Excel file provided by MAFF and joins
its tabular contents to agricultural community boundary data.

## Usage

``` r
read_ikasudb(boundary, path, na = c("-", "…"), zero = TRUE)
```

## Arguments

- boundary:

  Agricultural community boundary data, typically returned by
  [`get_boundary()`](https://takeshinishimura.github.io/fude/reference/get_boundary.md).
  This can be a single boundary object or a list of boundary objects.

- path:

  Path to an `.xlsx` file.

- na:

  Character vector of strings to interpret as missing values. Defaults
  to `c("-", "\u2026")`.

- zero:

  Logical. If `TRUE`, treat masked values (`"x"` and `"X"`) as zero
  before numeric conversion.

## Value

An [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) object
created by joining the Excel data to `boundary`.

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md)
