
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fude

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/fude)](https://CRAN.R-project.org/package=fude)
<!-- badges: end -->

The fude package provides utilities to facilitate handling of Fude
Polygon data downloadable from the Ministry of Agriculture, Forestry and
Fisheries (MAFF) website. The word “fude” (“筆”) is a Japanese counter
suffix used when referring to land parcels.

## Get Data

Download the Fude Polygon data from the following release site of MAFF.

- <https://open.fude.maff.go.jp> (Only Japanese is available.)

## Installation

You can install the released version of fude from CRAN:

``` r
install.packages("fude")
```

Or the development version from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("takeshinishimura/fude")
```

## Example

You can let R read the downloaded ZIP file without unzipping it. This
function was inspired by [kokudosuuchi: Utilities for ‘Kokudo
Suuchi’](https://CRAN.R-project.org/package=kokudosuuchi).

``` r
library(fude)

d <- read_fude("~/2022_382019.zip")
#> Reading layer `2022_382019' from data source 
#>   `/private/var/folders/33/1nmp7drn6c56394qxrzb2cth0000gn/T/RtmpSwKNVN/file1425474b56450/2022_382019.json' 
#>   using driver `GeoJSON'
#> Simple feature collection with 72045 features and 10 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 132.4962 ymin: 33.70162 xmax: 132.8954 ymax: 34.01602
#> Geodetic CRS:  WGS 84
```

You can change the local government code to the Japanese municipality
name for easier handling.

``` r
d <- rename_fude(d)
#> 2022_382019 -> 2022_松山市
```
