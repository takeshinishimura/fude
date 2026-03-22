# List the contents of Fude Polygon data

`ls_fude()` summarizes the contents of a Fude Polygon data object
returned by
[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).
It reports the data name, issue year, local government code, number of
records, and corresponding prefecture and municipality names.

## Usage

``` r
ls_fude(data)
```

## Arguments

- data:

  A Fude Polygon data object returned by
  [`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

## Value

A data frame with one row per combination of data name, issue year, and
local government code.

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md)
