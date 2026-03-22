# Extract specified agricultural community boundary data

`extract_boundary()` extracts subsets of agricultural community boundary
data returned by
[`get_boundary()`](https://takeshinishimura.github.io/fude/reference/get_boundary.md)
by municipality, former municipality, and/or agricultural community.

## Usage

``` r
extract_boundary(boundary, city = "", kcity = "", rcom = "", layer = FALSE)
```

## Arguments

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

- layer:

  Logical. If `TRUE`, return a list containing extracted agricultural
  community boundaries together with former municipality, municipality,
  and prefecture boundary layers.

## Value

If `layer = FALSE`, an
[`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) object.
If `layer = TRUE`, a named list of
[`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) objects.

## See also

[`get_boundary()`](https://takeshinishimura.github.io/fude/reference/get_boundary.md)
