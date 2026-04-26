# Read Fude Polygon data from a ZIP file

`read_fude()` reads MAFF Fude Polygon data from a ZIP file and returns
the layers as a named list of
[`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) objects.
If `path` is not supplied, the function downloads the ZIP file for the
specified prefecture and year using `pref`, `year`, and `rcom_year`.

The ZIP archive may contain one or more supported spatial files in
GeoJSON (`.json` or `.geojson`) or FlatGeobuf (`.fgb`) format. The
function also works with ZIP files created manually, provided that the
original file names are preserved.

## Usage

``` r
read_fude(
  path = NULL,
  pref = NULL,
  year = 2025,
  rcom_year = 2020,
  crs = NULL,
  supplementary = FALSE,
  quiet = FALSE
)
```

## Arguments

- path:

  Path to a ZIP file containing one or more supported spatial files. If
  `NULL`, the file is downloaded automatically from the MAFF website
  using `pref`, `year`, and `rcom_year`.

- pref:

  Prefecture name or prefecture code used when downloading data. Ignored
  if `path` is supplied.

- year:

  The Fude Polygon data year used in the download file name.

- rcom_year:

  The agricultural community boundary year used in the download file
  name.

- crs:

  Coordinate reference system to transform the output layers to. If
  `NULL`, the original CRS is kept.

- supplementary:

  Logical. If `TRUE`, add supplementary columns such as land-use labels
  and polygon area.

- quiet:

  Logical. If `TRUE`, suppress messages during download and reading.

## Value

A named list of
[`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) objects.

## Examples

``` r
path <- system.file("extdata", "castle.zip", package = "fude")
d <- read_fude(path)
#> Reading layer `2021_382019' from data source 
#>   `/private/var/folders/34/cc5j3spj0xs23b_r3j27pcr00000gn/T/RtmpPezhSs/file53816ed316d/castle/2021_382019.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.7653 ymin: 33.84506 xmax: 132.7662 ymax: 33.84575
#> Geodetic CRS:  WGS 84
#> Reading layer `2022_382019' from data source 
#>   `/private/var/folders/34/cc5j3spj0xs23b_r3j27pcr00000gn/T/RtmpPezhSs/file53816ed316d/castle/2022_382019.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.7653 ymin: 33.84506 xmax: 132.7662 ymax: 33.84575
#> Geodetic CRS:  WGS 84
#> Reading layer `2022_382078' from data source 
#>   `/private/var/folders/34/cc5j3spj0xs23b_r3j27pcr00000gn/T/RtmpPezhSs/file53816ed316d/castle/2022_382078.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 1 feature and 7 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.541 ymin: 33.50931 xmax: 132.5415 ymax: 33.50966
#> Geodetic CRS:  WGS 84
```
