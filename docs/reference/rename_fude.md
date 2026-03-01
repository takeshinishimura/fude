# Rename the Fude Polygon data

`rename_fude()` renames the 6-digit local government code of the list
returned by
[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md)
to the corresponding Japanese name in order to make the data
human-friendly.

## Usage

``` r
rename_fude(data, suffix = TRUE, romaji = NULL, quiet = TRUE)
```

## Arguments

- data:

  Fude Polygon data as returned by
  [`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

- suffix:

  Logical. If `FALSE`, suffixes such as "-SHI" and "-KU" in local
  government names are removed.

- romaji:

  If not `NULL`, rename the local government name in romaji instead of
  Japanese. Romanji format is upper case unless specified.

  - `"title"`: Title case.

  - `"lower"`: Lower case.

  - `"upper"`: Upper case.

- quiet:

  Logical. Suppress information about the data to be read.

## Value

A list of [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
objects.

## See also

[`read_fude()`](https://takeshinishimura.github.io/fude/reference/read_fude.md).

## Examples

``` r
path <- system.file("extdata", "castle.zip", package = "fude")
d <- read_fude(path, quiet = FALSE)
#> Reading layer `2021_382019' from data source 
#>   `/private/var/folders/33/1nmp7drn6c56394qxrzb2cth0000gn/T/RtmpAtsj8B/file2adb27daf56/castle/2021_382019.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.7653 ymin: 33.84506 xmax: 132.7662 ymax: 33.84575
#> Geodetic CRS:  WGS 84
#> Reading layer `2022_382019' from data source 
#>   `/private/var/folders/33/1nmp7drn6c56394qxrzb2cth0000gn/T/RtmpAtsj8B/file2adb27daf56/castle/2022_382019.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.7653 ymin: 33.84506 xmax: 132.7662 ymax: 33.84575
#> Geodetic CRS:  WGS 84
#> Reading layer `2022_382078' from data source 
#>   `/private/var/folders/33/1nmp7drn6c56394qxrzb2cth0000gn/T/RtmpAtsj8B/file2adb27daf56/castle/2022_382078.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.541 ymin: 33.50931 xmax: 132.5415 ymax: 33.50966
#> Geodetic CRS:  WGS 84
d2 <- rename_fude(d)
d2 <- rename_fude(d, suffix = FALSE)
d2 <- d |> rename_fude(romaji = "upper")
```
