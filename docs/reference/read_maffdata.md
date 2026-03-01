# Read MAFF data

`read_maffdata()` extracts the specified data from the list returned by
[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

## Usage

``` r
read_maffdata(path, boundary, extra_na = c("x", "X", "-", "…"))
```

## Arguments

- path:

  Path to the xls/xlsx file.

- boundary:

  Agricultural community boundary data as returned by
  [`get_boundary()`](https://takeshinishimura.github.io/fude/reference/get_boundary.md).

- extra_na:

  extra_na = c("x", "-")

## Value

A list of [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
object(s).
