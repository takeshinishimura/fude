# Extract specified agricultural community boundary data

`extract_boundary()` extracts the specified data from the list returned
by
[`get_boundary()`](https://takeshinishimura.github.io/fude/reference/get_boundary.md).

## Usage

``` r
extract_boundary(boundary, city = "", kcity = "", rcom = "", layer = FALSE)
```

## Arguments

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

- layer:

  Logical.

## Value

A list of [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
object(s).

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).
