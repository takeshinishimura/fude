# Rename Fude Polygon data

`rename_fude()` renames the elements of a Fude Polygon data object
returned by
[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md)
by replacing local government codes in the element names with
corresponding municipality names, making the object easier to read.

## Usage

``` r
rename_fude(data, suffix = TRUE, romaji = NULL, quiet = TRUE)
```

## Arguments

- data:

  A Fude Polygon data object returned by
  [`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

- suffix:

  Logical. If `FALSE`, municipality suffixes are removed from renamed
  element names. For example, romaji suffixes such as `"-shi"` and
  `"-ku"` are removed when `romaji` is used.

- romaji:

  Character scalar or `NULL`. If `NULL`, Japanese municipality names are
  used. Otherwise, municipality names are converted to romaji. Supported
  values are: `"upper"` for upper case, `"title"` for title case, and
  `"lower"` for lower case.

- quiet:

  Logical. If `FALSE`, print the mapping from old names to new names.

## Value

A Fude Polygon data object with renamed elements.

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md)

## Examples

``` r
path <- system.file("extdata", "castle.zip", package = "fude")
d <- read_fude(path, quiet = FALSE)
#> Reading layer `2021_382019' from data source 
#>   `/private/var/folders/34/cc5j3spj0xs23b_r3j27pcr00000gn/T/RtmpPezhSs/file5381113416aa/castle/2021_382019.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.7653 ymin: 33.84506 xmax: 132.7662 ymax: 33.84575
#> Geodetic CRS:  WGS 84
#> Reading layer `2022_382019' from data source 
#>   `/private/var/folders/34/cc5j3spj0xs23b_r3j27pcr00000gn/T/RtmpPezhSs/file5381113416aa/castle/2022_382019.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.7653 ymin: 33.84506 xmax: 132.7662 ymax: 33.84575
#> Geodetic CRS:  WGS 84
#> Reading layer `2022_382078' from data source 
#>   `/private/var/folders/34/cc5j3spj0xs23b_r3j27pcr00000gn/T/RtmpPezhSs/file5381113416aa/castle/2022_382078.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.541 ymin: 33.50931 xmax: 132.5415 ymax: 33.50966
#> Geodetic CRS:  WGS 84
d2 <- rename_fude(d)
d2 <- rename_fude(d, suffix = FALSE)
d2 <- rename_fude(d, romaji = "upper")
```
