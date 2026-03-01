# Extract specified agricultural community boundary data

`extract_boundary()` extracts specified subsets of agricultural
community boundary data returned by
[`get_boundary()`](https://takeshinishimura.github.io/fude/reference/get_boundary.md).

## Usage

``` r
extract_boundary(boundary, city = "", kcity = "", rcom = "", layer = FALSE)
```

## Arguments

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

- layer:

  Logical. If `TRUE`, the returned object includes not only agricultural
  community boundaries but also prefecture and municipality boundaries.

## Value

An [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
object.

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).
