# Bind multiple Fude Polygon data

`bind_fude()` binds a list of polygon data. It also binds a list of data
combined by
[`combine_fude()`](https://takeshinishimura.github.io/fude/reference/combine_fude.md).

## Usage

``` r
bind_fude(...)
```

## Arguments

- ...:

  Database lists to be combined. They should all have the same named
  elements.

## Value

A list of [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
object(s).

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md),
[`combine_fude()`](https://takeshinishimura.github.io/fude/reference/combine_fude.md).

## Examples

``` r
path <- system.file("extdata", "castle.zip", package = "fude")
d1 <- read_fude(path, quiet = TRUE)
d2 <- read_fude(path, quiet = TRUE)
bind_fude(d1, d2)
#> $`2021_382019`
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.7653 ymin: 33.84506 xmax: 132.7662 ymax: 33.84575
#> Geodetic CRS:  JGD2000
#> # A tibble: 1 × 8
#>   polygon_uuid    X_color X_opacity X_weight X_fillColor X_fillOpacity
#>   <chr>           <chr>       <dbl>    <int> <chr>               <dbl>
#> 1 dummy-uuid-0001 #000000       0.5        3 #ff0000               0.5
#> # ℹ 2 more variables: local_government_cd <chr>, geometry <POLYGON [°]>
#> 
#> $`2022_382019`
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.7653 ymin: 33.84506 xmax: 132.7662 ymax: 33.84575
#> Geodetic CRS:  JGD2000
#> # A tibble: 1 × 8
#>   polygon_uuid    X_color X_opacity X_weight X_fillColor X_fillOpacity
#>   <chr>           <chr>       <dbl>    <int> <chr>               <dbl>
#> 1 dummy-uuid-0002 #000000       0.5        3 #ff0000               0.5
#> # ℹ 2 more variables: local_government_cd <chr>, geometry <POLYGON [°]>
#> 
#> $`2022_382078`
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.541 ymin: 33.50931 xmax: 132.5415 ymax: 33.50966
#> Geodetic CRS:  JGD2000
#> # A tibble: 1 × 8
#>   polygon_uuid    X_color X_opacity X_weight X_fillColor X_fillOpacity
#>   <chr>           <chr>       <dbl>    <int> <chr>               <dbl>
#> 1 dummy-uuid-0003 #000000       0.5        3 #ff0000               0.5
#> # ℹ 2 more variables: local_government_cd <chr>, geometry <POLYGON [°]>
#> 
```
