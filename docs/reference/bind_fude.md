# Bind multiple Fude Polygon data objects

`bind_fude()` combines multiple Fude Polygon data objects by binding
elements with the same names across inputs. It can also be used on
objects that have already been combined by
[`combine_fude()`](https://takeshinishimura.github.io/fude/reference/combine_fude.md).

## Usage

``` r
bind_fude(...)
```

## Arguments

- ...:

  Two or more Fude Polygon data objects to combine. Named elements that
  appear in multiple inputs are row-bound into a single
  [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) object.

## Value

A named list of
[`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) objects.

## See also

[`combine_fude()`](https://takeshinishimura.github.io/fude/reference/combine_fude.md)

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
#> Geodetic CRS:  WGS 84
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
#> Geodetic CRS:  WGS 84
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
#> Geodetic CRS:  WGS 84
#> # A tibble: 1 × 8
#>   polygon_uuid    X_color X_opacity X_weight X_fillColor X_fillOpacity
#>   <chr>           <chr>       <dbl>    <int> <chr>               <dbl>
#> 1 dummy-uuid-0003 #000000       0.5        3 #ff0000               0.5
#> # ℹ 2 more variables: local_government_cd <chr>, geometry <POLYGON [°]>
#> 
```
