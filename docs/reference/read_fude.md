# Read a Fude Polygon ZIP file

`read_fude()` reads MAFF Fude Polygon data from a ZIP file and returns
the layers as a list of
[`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) objects.
The ZIP may contain one or more spatial data files such as **GeoJSON**
(`.json` or `.geojson`) and **FlatGeobuf** (`.fgb`). The function also
works with ZIP files you created, as long as the original filenames are
unchanged.

## Usage

``` r
read_fude(
  path = NULL,
  pref = NULL,
  year = 2025,
  rcom_year = 2020,
  supplementary = FALSE,
  to_wgs84 = FALSE,
  quiet = FALSE
)
```

## Arguments

- path:

  Path to a ZIP file containing one or more supported spatial files
  (`.geojson`, `.json`, and `.fgb`).

- pref:

  Prefecture name or a two-digit prefecture code.

- year:

  Year when the Fude Polygon data were created.

- rcom_year:

  Year of the agricultural community boundary data.

- supplementary:

  Logical. If `TRUE`, add supplementary information for each polygon.

- to_wgs84:

  Logical. If `TRUE`, transform coordinates to WGS 84 (EPSG:4326).

- quiet:

  Logical. If `TRUE`, suppress messages about reading progress.

## Value

A list of [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
objects.

## Examples

``` r
path <- system.file("extdata", "castle.zip", package = "fude")
d <- read_fude(path)
#> Reading layer `2021_382019' from data source 
#>   `/private/var/folders/33/1nmp7drn6c56394qxrzb2cth0000gn/T/Rtmp2N0y4h/file7d546edcad79/castle/2021_382019.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.7653 ymin: 33.84506 xmax: 132.7662 ymax: 33.84575
#> Geodetic CRS:  WGS 84
#> Reading layer `2022_382019' from data source 
#>   `/private/var/folders/33/1nmp7drn6c56394qxrzb2cth0000gn/T/Rtmp2N0y4h/file7d546edcad79/castle/2022_382019.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.7653 ymin: 33.84506 xmax: 132.7662 ymax: 33.84575
#> Geodetic CRS:  WGS 84
#> Reading layer `2022_382078' from data source 
#>   `/private/var/folders/33/1nmp7drn6c56394qxrzb2cth0000gn/T/Rtmp2N0y4h/file7d546edcad79/castle/2022_382078.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.541 ymin: 33.50931 xmax: 132.5415 ymax: 33.50966
#> Geodetic CRS:  WGS 84
```
