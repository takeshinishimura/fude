# Generate citation text for Fude Polygon data

Generates citation text in Japanese and English for Fude Polygon Data.

## Usage

``` r
cite_fude(data)
```

## Arguments

- data:

  A list or data frame containing Fude Polygon data.

## Value

A list with two elements: `ja` for Japanese citation text and `en` for
English citation text.

## Examples

``` r
data <- list(fude = data.frame(issue_year = c(2021, 2020), boundary_data_year = c(2019, 2020)))
cite_fude(data)
#> $ja
#> 農林水産省「筆ポリゴンデータ（2020，2021年度公開）」および「農業集落境界データ（2019，2020年度）」を加工して作成。
#> 
#> $en
#> Created by processing the Ministry of Agriculture, Forestry and Fisheries, 'Fude Polygon Data (released in FY2020, 2021)' and 'Agricultural Community Boundary Data (FY2019, 2020)'.
#> 
```
