# Generate citation text for Fude Polygon data

`cite_fude()` generates citation text in Japanese and English from Fude
Polygon data and related boundary data.

## Usage

``` r
cite_fude(data)
```

## Arguments

- data:

  A Fude Polygon data object, boundary data object, or a data frame/list
  containing `issue_year` and/or `boundary_data_year`.

## Value

A list with two elements: `ja` for Japanese citation text and `en` for
English citation text.
