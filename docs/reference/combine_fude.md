# Combine the Fude Polygon data with the agricultural community boundary data

`combine_fude()` uses the agricultural community boundary data to reduce
the Fude Polygon data to the community units.

## Usage

``` r
combine_fude(data, boundary, city, kcity = "", rcom = "", year = NULL)
```

## Arguments

- data:

  List of MAFF Fude Polygon data.

- boundary:

  List of one or more MAFF agricultural community boundary data.

- city:

  A local government name in Japanese to be extracted. In the case of
  overlapping local government names, this must contain the prefecture
  name in Japanese and the prefecture code in romaji (e.g., "Fuchu-shi,
  13", "fuchu 13", "34 fuchu-shi", "34, FUCHU-CHO"). Alternatively, it
  could be a 6-digit local government code.

- kcity:

  A regular expression string. One or more former city names (in
  Japanese) to extract.

- rcom:

  A regular expression string. One or more agricultural community names
  (in Japanese) to extract.

- year:

  Year in the column name of the `data`. If there is more than one
  applicable local government code, it is required.

## Value

A list of [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
objects.

@seealso
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
