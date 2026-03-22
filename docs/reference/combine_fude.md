# Combine Fude Polygon data with agricultural community boundary data

`combine_fude()` combines Fude Polygon data with agricultural community
boundary data and returns the polygons associated with the specified
municipality, former municipality, and/or agricultural community.

## Usage

``` r
combine_fude(data, boundary, city, kcity = "", rcom = "", year = NULL)
```

## Arguments

- data:

  A Fude Polygon data object returned by
  [`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

- boundary:

  Agricultural community boundary data returned by
  [`get_boundary()`](https://takeshinishimura.github.io/fude/reference/get_boundary.md).

- city:

  A character vector of municipality names or local government codes
  used to identify target municipalities. If `NULL`, all municipalities
  are kept.

- kcity:

  A character vector of regular expression patterns used to match former
  municipality names in Japanese.

- rcom:

  A character vector of regular expression patterns used to match
  agricultural community names in Japanese.

- year:

  Numeric scalar or `NULL`. When multiple Fude Polygon datasets match
  the specified municipality, `year` is used to choose the target
  dataset.

## Value

A named list of
[`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) objects.

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md),
[`get_boundary()`](https://takeshinishimura.github.io/fude/reference/get_boundary.md)

## Examples

``` r
if (FALSE) { # interactive()
path <- system.file("extdata", "castle.zip", package = "fude")
d <- read_fude(path)
b <- get_boundary(d)
db <- combine_fude(d, b, "\u677e\u5c71\u5e02", "\u57ce\u6771", year = 2022)
}
```
