# Extract specified Fude Polygon data

`extract_fude()` extracts the specified data from the list returned by
[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

## Usage

``` r
extract_fude(data, year = NULL, city = NULL, kcity = "", rcom = "")
```

## Arguments

- data:

  List of MAFF Fude Polygon data.

- year:

  One or more years to extract.

- city:

  A local government name or code (6-digit) to extract.

- kcity:

  A regular expression string. One or more former city names (in
  Japanese) to extract.

- rcom:

  A regular expression string. One or more agricultural community names
  (in Japanese) to extract.

## Value

A list of [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
object(s).

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).
