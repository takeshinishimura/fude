
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fude

<!-- badges: start -->

[![R-CMD-check](https://github.com/takeshinishimura/fude/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/takeshinishimura/fude/actions/workflows/check-standard.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/fude)](https://CRAN.R-project.org/package=fude)
<!-- badges: end -->

The fude package provides utilities to facilitate the handling of the
Fude Polygon data downloadable from the Ministry of Agriculture,
Forestry and Fisheries (MAFF) website. The word “fude” is a Japanese
counter suffix used to denote land parcels.

## Obtaining Data

Download the Fude Polygon data from the following MAFF release site
(available only in Japanese):

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

### Reading Fude Polygon Data

You can let R read the downloaded ZIP file directly without unzipping
it.

``` r
library(fude)
d <- read_fude("~/2022_38.zip")
```

### Renaming Columns

You can convert local government codes into Japanese municipality names
for easier management.

``` r
d2 <- rename_fude(d)
names(d2)
#>  [1] "2022_松山市"     "2022_今治市"     "2022_宇和島市"   "2022_八幡浜市"  
#>  [5] "2022_新居浜市"   "2022_西条市"     "2022_大洲市"     "2022_伊予市"    
#>  [9] "2022_四国中央市" "2022_西予市"     "2022_東温市"     "2022_上島町"    
#> [13] "2022_久万高原町" "2022_松前町"     "2022_砥部町"     "2022_内子町"    
#> [17] "2022_伊方町"     "2022_松野町"     "2022_鬼北町"     "2022_愛南町"
```

You can also rename the columns to Romaji instead of Japanese.

``` r
d2 <- d |> rename_fude(suffix = TRUE, romaji = "title")
names(d2)
#>  [1] "2022_Matsuyama-shi"   "2022_Imabari-shi"     "2022_Uwajima-shi"    
#>  [4] "2022_Yawatahama-shi"  "2022_Niihama-shi"     "2022_Saijo-shi"      
#>  [7] "2022_Ozu-shi"         "2022_Iyo-shi"         "2022_Shikokuchuo-shi"
#> [10] "2022_Seiyo-shi"       "2022_Toon-shi"        "2022_Kamijima-cho"   
#> [13] "2022_Kumakogen-cho"   "2022_Matsumae-cho"    "2022_Tobe-cho"       
#> [16] "2022_Uchiko-cho"      "2022_Ikata-cho"       "2022_Matsuno-cho"    
#> [19] "2022_Kihoku-cho"      "2022_Ainan-cho"
```

### Getting Agricultural Community Boundary Data

You can download the agricultural community boundary data, which
corresponds to the Fude Polygon data, from the MAFF website at
<https://www.maff.go.jp/j/tokei/census/shuraku_data/2020/ma/> (available
only in Japanese).

``` r
b <- get_boundary(d)
```

You can easily create a map that combines Fude Polygons with
agricultural community boundaries.

``` r
db <- combine_fude(d, b, city = "松山市", community = "由良|北浦|鷲ケ巣|門田|馬磯|泊|御手洗|船越")

library(ggplot2)

ggplot() +
  geom_sf(data = db$fude_split, aes(fill = RCOM_NAME)) +
  guides(fill = guide_legend(reverse = TRUE, title = "興居島の集落別耕地")) +
  theme_void() +
  theme(text = element_text(family = "Hiragino Sans"))
```

<img src="man/figures/README-gogoshima-1.png" width="100%" />

**出典**：農林水産省「筆ポリゴンデータ（2022年度公開）」および「農業集落境界データ（2022年度）」を加工して作成。

Polygon data near community borders may be divided. To avoid this, use
`db$fude`.

``` r
library(ggforce)

ggplot() +
  geom_sf(data = db$community, fill = NA) +
  geom_sf(data = db$fude, aes(fill = RCOM_ROMAJI)) +
  geom_mark_hull(data = db$fude, 
                 aes(x = point_lng, y = point_lat,
                     fill = RCOM_ROMAJI,
                     label = RCOM_ROMAJI),
                 colour = NA,
                 expand = unit(1, "mm"),
                 radius = unit(1, "mm"),
                 label.fontsize = 9,
                 label.family = "Helvetica",
                 label.fill = NA,
                 label.colour = "black",
                 label.buffer = unit(1, "mm"),
                 con.colour = "gray70") +
  theme_void() +
  theme(legend.position = "none")
```

<img src="man/figures/README-nosplit_gogoshima-1.png" width="100%" />

**Source**: Created by processing the Ministry of Agriculture, Forestry
and Fisheries, ‘Fude Polygon Data (released in FY2022)’ and
‘Agricultural Community Boundary Data (FY2022)’.

Polygons on community boundaries are not divided but are assigned to one
of the communities. If you need to adjust this automatic assignment, you
will need to write custom code. The rows that require attention can be
identified with the following command.

``` r
library(dplyr)
library(sf)

# head(sf::st_drop_geometry(db$fude[db$fude$polygon_uuid %in% db$fude_split$polygon_uuid[duplicated(db$fude_split$polygon_uuid)], c("polygon_uuid", "PREF_NAME", "CITY_NAME", "KCITY_NAME", "RCOM_NAME", "RCOM_KANA", "RCOM_ROMAJI")]))
db$fude |>
  filter(polygon_uuid %in% (db$fude_split |> filter(duplicated(polygon_uuid)) |> pull(polygon_uuid))) |>
  sf::st_drop_geometry() |>
  select(polygon_uuid, KCITY_NAME, RCOM_NAME, RCOM_KANA, RCOM_ROMAJI) |>
  head()
#> # A tibble: 6 × 5
#>   polygon_uuid                        KCITY_NAME RCOM_NAME RCOM_KANA RCOM_ROMAJI
#>   <chr>                               <fct>      <fct>     <fct>     <fct>      
#> 1 8085bc47-9af5-440f-89e9-f188d3b957… 興居島村   泊        とまり    Tomari     
#> 2 26920da0-b63e-4994-a9eb-175e2982fe… 興居島村   門田      かどた    Kadota     
#> 3 ac2e7293-6c2f-4feb-a95f-4729dc8d0a… 興居島村   由良      ゆら      Yura       
#> 4 ea130038-7035-4cf3-b71c-091783090d… 興居島村   船越      ふなこし  Funakoshi  
#> 5 4aba8229-1b14-4eab-8a91-e10d9e8411… 興居島村   船越      ふなこし  Funakoshi  
#> 6 156a3459-25cb-494c-824f-9ba6b0fb6f… 興居島村   由良      ゆら      Yura
```

### Visualizing Fude Polygon Data

You can confirm Fude Polygon data in detail.

``` r
library(shiny)

s <- shiny_fude(db, community = TRUE)
# shiny::shinyApp(ui = s$ui, server = s$server)
```

This feature was heavily inspired by the following website:
<https://brendenmsmith.com/blog/shiny_map_filter/>.

### Using `mapview` package

If you want to use `mapview()`, do the following.

``` r
db1 <- combine_fude(d, b, city = "伊方町")
db2 <- combine_fude(d, b, city = "八幡浜市")
db3 <- combine_fude(d, b, city = "西予市", old_village = "三瓶|二木生|三島|双岩")
db <- bind_fude(db1, db2, db3)

library(mapview)

mapview::mapview(db$fude, zcol = "RCOM_NAME", layer.name = "農業集落名")
```
