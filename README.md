
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fude

<!-- badges: start -->

[![R-CMD-check](https://github.com/takeshinishimura/fude/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/takeshinishimura/fude/actions/workflows/check-standard.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/fude)](https://CRAN.R-project.org/package=fude)
<!-- badges: end -->

The fude package provides utilities to facilitate handling of Fude
Polygon data downloadable from the Ministry of Agriculture, Forestry and
Fisheries (MAFF) website. The word fude is a Japanese counter suffix
used when referring to land parcels.

## Obtaining Data

Download the Fude Polygon data from the following release site of MAFF
(only Japanese is available).

- <https://open.fude.maff.go.jp>

## Installation

You can install the released version of fude from CRAN with:

``` r
install.packages("fude")
```

Or the development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("takeshinishimura/fude")
```

## Usage

You can let R read the downloaded ZIP file without unzipping it.

``` r
library(fude)
d <- read_fude("~/2022_38.zip")
```

Those who wish to use a mouse or trackpad for file selection, which is
especially common among R beginners, can do the following.

``` r
d <- read_fude(file.choose())
```

You can rename the local government codes to the Japanese municipality
names for easier handling.

``` r
d2 <- rename_fude(d)
#> 2022_382019 -> 2022_松山市
#> 2022_382027 -> 2022_今治市
#> 2022_382035 -> 2022_宇和島市
#> 2022_382043 -> 2022_八幡浜市
#> 2022_382051 -> 2022_新居浜市
#> 2022_382060 -> 2022_西条市
#> 2022_382078 -> 2022_大洲市
#> 2022_382108 -> 2022_伊予市
#> 2022_382132 -> 2022_四国中央市
#> 2022_382141 -> 2022_西予市
#> 2022_382159 -> 2022_東温市
#> 2022_383562 -> 2022_上島町
#> 2022_383864 -> 2022_久万高原町
#> 2022_384011 -> 2022_松前町
#> 2022_384020 -> 2022_砥部町
#> 2022_384224 -> 2022_内子町
#> 2022_384429 -> 2022_伊方町
#> 2022_384844 -> 2022_松野町
#> 2022_384887 -> 2022_鬼北町
#> 2022_385069 -> 2022_愛南町
```

It can also be renamed to romaji instead of Japanese.

``` r
d3 <- d |> rename_fude(suffix = TRUE, romaji = "title", quiet = TRUE)
names(d3)
#>  [1] "2022_Matsuyama-shi"   "2022_Imabari-shi"     "2022_Uwajima-shi"    
#>  [4] "2022_Yawatahama-shi"  "2022_Niihama-shi"     "2022_Saijo-shi"      
#>  [7] "2022_Ozu-shi"         "2022_Iyo-shi"         "2022_Shikokuchuo-shi"
#> [10] "2022_Seiyo-shi"       "2022_Toon-shi"        "2022_Kamijima-cho"   
#> [13] "2022_Kumakogen-cho"   "2022_Matsumae-cho"    "2022_Tobe-cho"       
#> [16] "2022_Uchiko-cho"      "2022_Ikata-cho"       "2022_Matsuno-cho"    
#> [19] "2022_Kihoku-cho"      "2022_Ainan-cho"
```

You can download the agricultural community boundary data corresponding
to the Fude Polygon data from the MAFF website
<https://www.maff.go.jp/j/tokei/census/shuraku_data/2020/ma/index.html>.

``` r
b <- get_boundary(d2)
```

You can draw a map combining Fude Polygons and agricultural community
boundaries.

``` r
library(ggplot2)
library(dplyr)

db <- combine_fude(d2, b, city = "松山市", community = "由良|北浦|鷲ケ巣|門田|馬磯|泊|御手洗|船越")

ggplot() +
  geom_sf(data = db$fude, aes(fill = RCOM_NAME)) +
  geom_sf(data = db$boundary, fill = NA) +
  guides(fill = guide_legend(reverse = TRUE, title = "興居島の集落別耕地")) +
  theme_void()
```

<img src="man/figures/README-gogoshima-1.png" width="100%" />
