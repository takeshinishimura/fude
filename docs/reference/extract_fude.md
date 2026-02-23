# Extract specified Fude Polygon data

`extract_fude()` extracts the specified data from the list returned by
[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

## Usage

``` r
extract_fude(data, year = NULL, city = NULL, kcity = "", community = "")
```

## Arguments

- data:

  A list of
  [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
  objects.

- year:

  One or more years to extract.

- city:

  Local government names or codes to extract.

- kcity:

  A regular expression string. One or more former village names (in
  Japanese) to extract.

- community:

  A regular expression string. One or more agricultural community names
  (in Japanese) to extract.

## Value

A list of [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
object(s).

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).
