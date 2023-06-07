
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

You can let R read the downloaded ZIP file without unzipping it. This
function was inspired by [kokudosuuchi: Utilities for ‘Kokudo
Suuchi’](https://CRAN.R-project.org/package=kokudosuuchi).

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
d3 <- d |> rename_fude(suffix = TRUE, romaji = "title")
#> 2022_382019 -> 2022_Matsuyama-shi
#> 2022_382027 -> 2022_Imabari-shi
#> 2022_382035 -> 2022_Uwajima-shi
#> 2022_382043 -> 2022_Yawatahama-shi
#> 2022_382051 -> 2022_Niihama-shi
#> 2022_382060 -> 2022_Saijo-shi
#> 2022_382078 -> 2022_Ozu-shi
#> 2022_382108 -> 2022_Iyo-shi
#> 2022_382132 -> 2022_Shikokuchuo-shi
#> 2022_382141 -> 2022_Seiyo-shi
#> 2022_382159 -> 2022_Toon-shi
#> 2022_383562 -> 2022_Kamijima-cho
#> 2022_383864 -> 2022_Kumakogen-cho
#> 2022_384011 -> 2022_Matsumae-cho
#> 2022_384020 -> 2022_Tobe-cho
#> 2022_384224 -> 2022_Uchiko-cho
#> 2022_384429 -> 2022_Ikata-cho
#> 2022_384844 -> 2022_Matsuno-cho
#> 2022_384887 -> 2022_Kihoku-cho
#> 2022_385069 -> 2022_Ainan-cho
d3 <- d |> rename_fude(suffix = FALSE, romaji = "upper")
#> 2022_382019 -> 2022_MATSUYAMA
#> 2022_382027 -> 2022_IMABARI
#> 2022_382035 -> 2022_UWAJIMA
#> 2022_382043 -> 2022_YAWATAHAMA
#> 2022_382051 -> 2022_NIIHAMA
#> 2022_382060 -> 2022_SAIJO
#> 2022_382078 -> 2022_OZU
#> 2022_382108 -> 2022_IYO
#> 2022_382132 -> 2022_SHIKOKUCHUO
#> 2022_382141 -> 2022_SEIYO
#> 2022_382159 -> 2022_TOON
#> 2022_383562 -> 2022_KAMIJIMA
#> 2022_383864 -> 2022_KUMAKOGEN
#> 2022_384011 -> 2022_MATSUMAE
#> 2022_384020 -> 2022_TOBE
#> 2022_384224 -> 2022_UCHIKO
#> 2022_384429 -> 2022_IKATA
#> 2022_384844 -> 2022_MATSUNO
#> 2022_384887 -> 2022_KIHOKU
#> 2022_385069 -> 2022_AINAN
```
