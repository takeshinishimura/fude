# Combine the Fude Polygon data with the agricultural community boundary data

`combine_fude()` uses the agricultural community boundary data to reduce
the Fude Polygon data to the community units.

## Usage

``` r
combine_fude(data, boundary, city, kcity = "", rcom = "", year = NULL)
```

## Arguments

- data:

  Fude Polygon data as returned by
  [`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

- boundary:

  Agricultural community boundary data as returned by
  [`get_boundary()`](https://takeshinishimura.github.io/fude/reference/get_boundary.md).

- city:

  A character vector of local government names or 6-digit local
  government codes to extract.

- kcity:

  A regular expression. One or more former municipality names (in
  Japanese) to extract.

- rcom:

  A regular expression. One or more agricultural community names (in
  Japanese) to extract.

- year:

  Year in the column name of the `data`. If there is more than one
  applicable local government code, it is required.

## Value

A list of [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
objects.

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

## Examples

``` r
if (FALSE) { # interactive()
path <- system.file("extdata", "castle.zip", package = "fude")
d <- read_fude(path, stringsAsFactors = FALSE)
b <- get_boundary(d)
db <- combine_fude(d, b, "\u677e\u5c71\u5e02", "\u57ce\u6771", year = 2022)
}
```
