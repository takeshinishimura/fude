# Extract a subset of Fude Polygon data

`extract_fude()` extracts a subset of Fude Polygon data returned by
[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md)
by year, municipality, former municipality, and/or agricultural
community.

## Usage

``` r
extract_fude(data, year = NULL, city = NULL, kcity = "", rcom = "")
```

## Arguments

- data:

  A Fude Polygon data object returned by
  [`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).
  `data` may be a single data frame or a list of data frames.

- year:

  A numeric vector of issue years to extract. If `NULL`, all years are
  kept.

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

## Value

An [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) object
containing the extracted subset.

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md)
