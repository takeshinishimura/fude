# Extract specified Fude Polygon data

`extract_fude()` extracts specified subsets of Fude Polygon data
returned by
[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

## Usage

``` r
extract_fude(data, year = NULL, city = NULL, kcity = "", rcom = "")
```

## Arguments

- data:

  Fude Polygon data as returned by
  [`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

- year:

  A numeric vector of years to extract.

- city:

  A character vector of local government names or 6-digit local
  government codes to extract.

- kcity:

  A regular expression. One or more former municipality names (in
  Japanese) to extract.

- rcom:

  A regular expression. One or more agricultural community names (in
  Japanese) to extract.

## Value

An [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
object.

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).
