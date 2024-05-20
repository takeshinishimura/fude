
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

You can allow R to read the downloaded ZIP file directly without
unzipping it.

``` r
library(fude)
d <- read_fude("~/2022_38.zip")
```

For those who prefer using a mouse or trackpad to select files, a method
particularly popular among R beginners, the following approach can be
taken.

``` r
d <- read_fude(file.choose())
```

You can convert the local government codes into Japanese municipality
names for more convenient management.

``` r
d2 <- rename_fude(d)
names(d2)
#>  [1] "2022_松山市"     "2022_今治市"     "2022_宇和島市"   "2022_八幡浜市"  
#>  [5] "2022_新居浜市"   "2022_西条市"     "2022_大洲市"     "2022_伊予市"    
#>  [9] "2022_四国中央市" "2022_西予市"     "2022_東温市"     "2022_上島町"    
#> [13] "2022_久万高原町" "2022_松前町"     "2022_砥部町"     "2022_内子町"    
#> [17] "2022_伊方町"     "2022_松野町"     "2022_鬼北町"     "2022_愛南町"
```

It can also be renamed to romaji instead of Japanese.

``` r
d3 <- d |> rename_fude(suffix = TRUE, romaji = "title")
names(d3)
#>  [1] "2022_Matsuyama-shi"   "2022_Imabari-shi"     "2022_Uwajima-shi"    
#>  [4] "2022_Yawatahama-shi"  "2022_Niihama-shi"     "2022_Saijo-shi"      
#>  [7] "2022_Ozu-shi"         "2022_Iyo-shi"         "2022_Shikokuchuo-shi"
#> [10] "2022_Seiyo-shi"       "2022_Toon-shi"        "2022_Kamijima-cho"   
#> [13] "2022_Kumakogen-cho"   "2022_Matsumae-cho"    "2022_Tobe-cho"       
#> [16] "2022_Uchiko-cho"      "2022_Ikata-cho"       "2022_Matsuno-cho"    
#> [19] "2022_Kihoku-cho"      "2022_Ainan-cho"
```

You can download the agricultural community boundary data, which
corresponds to the Fude Polygon data, from the MAFF website at
<https://www.maff.go.jp/j/tokei/census/shuraku_data/2020/ma/> (available
only in Japanese).

``` r
b <- get_boundary(d)
```

You can effortlessly create a map that integrates Fude Polygons with
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
**出典**：農林水産省「筆ポリゴンデータ（2022年度公開）」および「農業集落境界データ（2020年度）」を加工して作成。

Polygon data close to community borders may be divided. To avoid this,
utilize `db$fude`.

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
  theme_no_axes() +
  theme(legend.position = "none")
```

<img src="man/figures/README-nosplit_gogoshima-1.png" width="100%" />
**Source**: Created by processing the Ministry of Agriculture, Forestry
and Fisheries, *Fude Polygon Data (released in FY2022)* and
*Agricultural Community Boundary Data (FY2020)*.

Polygons situated on community boundaries are not divided but are
allocated to one of the communities. Should there be a need to adjust
this automatic assignment, custom coding will be necessary. The rows
that require consideration can be extracted with the following command.

``` r
library(dplyr)
library(sf)

# head(sf::st_drop_geometry(db$fude[db$fude$polygon_uuid %in% db$fude_split$polygon_uuid[duplicated(db$fude_split$polygon_uuid)], c("polygon_uuid", "PREF_NAME", "CITY_NAME", "KCITY_NAME", "RCOM_NAME", "RCOM_KANA", "RCOM_ROMAJI")]))
db$fude |>
  filter(polygon_uuid %in% (db$fude_split |> filter(duplicated(polygon_uuid))  |> pull(polygon_uuid))) |>
  select(polygon_uuid, PREF_NAME, CITY_NAME, KCITY_NAME, RCOM_NAME, RCOM_KANA, RCOM_ROMAJI) |>
  sf::st_drop_geometry() |>
  head()
#>                           polygon_uuid PREF_NAME CITY_NAME KCITY_NAME RCOM_NAME
#> 1 8085bc47-9af5-440f-89e9-f188d3b95746    愛媛県    松山市   興居島村        泊
#> 2 26920da0-b63e-4994-a9eb-175e2982fe21    愛媛県    松山市   興居島村      門田
#> 3 ac2e7293-6c2f-4feb-a95f-4729dc8d0aec    愛媛県    松山市   興居島村      由良
#> 4 ea130038-7035-4cf3-b71c-091783090d74    愛媛県    松山市   興居島村      船越
#> 5 4aba8229-1b14-4eab-8a91-e10d9e841180    愛媛県    松山市   興居島村      船越
#> 6 156a3459-25cb-494c-824f-9ba6b0fb6f23    愛媛県    松山市   興居島村      由良
#>   RCOM_KANA RCOM_ROMAJI
#> 1    とまり      Tomari
#> 2    かどた      Kadota
#> 3      ゆら        Yura
#> 4  ふなこし   Funakoshi
#> 5  ふなこし   Funakoshi
#> 6      ゆら        Yura
```

The gghighlight package enables practical and effective visualization.

``` r
library(forcats)
library(gghighlight)

db$community <- db$community %>%
  mutate(across(c(RCOM_NAME, RCOM_KANA, RCOM_ROMAJI), forcats::fct_rev))
db$fude <- db$fude %>%
  mutate(across(c(RCOM_NAME, RCOM_KANA, RCOM_ROMAJI), forcats::fct_rev))

ggplot() +
  geom_sf(data = db$community, aes(fill = RCOM_NAME), alpha = 0) +
  geom_sf(data = db$fude, aes(fill = RCOM_NAME), linewidth = 0) +
  gghighlight() +
  facet_wrap(vars(RCOM_NAME)) +
  theme_void() +
  theme(legend.position = "none",
        text = element_text(family = "Hiragino Sans"))
```

<img src="man/figures/README-facet_wrap_gogoshima-1.png" width="100%" />
**出典**：農林水産省「筆ポリゴンデータ（2022年度公開）」および「農業集落境界データ（2020年度）」を加工して作成。

``` r
ggplot(data = db$fude, aes(x = as.numeric(a), fill = land_type_jp)) +
  geom_histogram(position = "identity", alpha = .5) +
  labs(x = "面積（a）",
       y = "頻度") +
  facet_wrap(vars(RCOM_NAME)) +
  labs(fill = "耕地の種類") +
  theme_minimal() +
  theme(text = element_text(family = "Hiragino Sans"))
```

<img src="man/figures/README-facet_wrap_gogoshima_hist-1.png" width="100%" />

There are 8 types of objects obtained by `combine_fude()`, as follows:

``` r
names(db)
#> [1] "fude"            "fude_split"      "community"       "community_union"
#> [5] "ov"              "lg"              "pref"            "source"
```

If you want to be particular about the details of the map, for example,
execute the following code.

``` r
db <- combine_fude(d, b, city = "松山市", old_village = "興居島", community = "^(?!釣島).*")

library(ggrepel)
library(cowplot)

minimap <- ggplot() +
  geom_sf(data = db$lg, aes(fill = fill)) +
  geom_sf_text(data = db$lg, aes(label = city_kanji), family = "Hiragino Sans") +
  gghighlight(fill == 1) +
  geom_sf(data = db$community_union, fill = "black", linewidth = 0) +
  theme_void() +
  theme(panel.background = element_rect(fill = "aliceblue")) +
  scale_fill_manual(values = c("white", "gray"))

mainmap <- ggplot() +
  geom_sf(data = db$community, fill = "white") +
  geom_sf(data = db$fude, aes(fill = RCOM_NAME)) +
  geom_point(data = db$community, aes(x = x, y = y), colour = "gray") +
  geom_text_repel(data = db$community,
                  aes(x = x, y = y, label = RCOM_NAME),
                  nudge_x = c(-.01, .01, -.01, -.012, .005, -.01, .01, .01),
                  nudge_y = c(.005, .005, 0, .01, -.005, .01, 0, -.005),
                  min.segment.length = .01,
                  segment.color = "gray",
                  size = 3,
                  family = "Hiragino Sans") +
  theme_void() +
  theme(legend.position = "none")

ggdraw(mainmap) +
  draw_plot(
    {minimap +
       geom_rect(aes(xmin = 132.47, xmax = 133.0,
                     ymin = 33.72, ymax = 34.05),
                 fill = NA,
                 colour = "black",
                 size = .5) +
       coord_sf(xlim = c(132.47, 133.0),
                ylim = c(33.72, 34.05),
                expand = FALSE) +
       theme(legend.position = "none")
    },
    x = .7, 
    y = 0,
    width = .3, 
    height = .3)
```

If you want to use `mapview()`, do the following.

``` r
db1 <- combine_fude(d, b, city = "伊方町")
db2 <- combine_fude(d, b, city = "八幡浜市")
db3 <- combine_fude(d, b, city = "西予市", old_village = "三瓶|二木生|三島|双岩")
db <- bind_fude(db1, db2, db3)

library(mapview)

mapview::mapview(db$fude, zcol = "RCOM_NAME", layer.name = "農業集落名")
```

The possible values for `community` in `combine_fude()` can be listed as
follows.

``` r
library(data.tree)

b[[1]] |>
  filter(grepl("松山", KCITY_NAME)) |>
  mutate(pathString = paste(PREF_NAME, CITY_NAME, KCITY_NAME, RCOM_NAME, sep = "/")) |>
  data.tree::as.Node() |>
  print(limit = 10)
#>                              levelName
#> 1  愛媛県                             
#> 2   °--松山市                        
#> 3       °--松山市                    
#> 4           ¦--土居田                
#> 5           ¦--針田                  
#> 6           ¦--小栗第１              
#> 7           ¦--小栗第２              
#> 8           ¦--小栗第３              
#> 9           ¦--藤原第１              
#> 10          °--... 102 nodes w/ 0 sub
```

``` r
ggplot(data = b[[1]] |> filter(grepl("松山", KCITY_NAME))) + 
  geom_sf(fill = NA) +
  geom_sf_text(aes(label = RCOM_NAME), size = 2, family = "Hiragino Sans") +
  theme_void()
```

<img src="man/figures/README-matsuyama-1.png" width="100%" />

You can also visualize the relationship between the residences of
farmers and their farmland.

``` r
db <- combine_fude(d, b, city = "松山", community = "和気|安城寺|長戸|久万ノ台")

set.seed(200)
probabilities <- c("A" = 0.97, "B" = 0.01, "C" = 0.005, "D" = 0.005, "E" = 0.005, "F" = 0.005)
db$fude$farmer = factor(sample(names(probabilities),
                               nrow(db$fude),
                               replace = TRUE,
                               prob = probabilities))

farm <- db$fude |>
  group_by(farmer) |>
  summarise(geometry = sf::st_union(geometry) |> sf::st_centroid()) |>
  sf::st_set_crs(4326)

farm_radius <- farm |>
  sf::st_transform(crs = sp::CRS("+init=epsg:32632")) |>
  sf::st_buffer(dist = units::as_units(1, "km")) |>
  sf::st_transform(crs = 4326)

library(osmdata)

bbox <- sf::st_bbox(db$fude)

streets <- bbox |>
  osmdata::opq() |>
  osmdata::add_osm_feature(key = "highway", 
                           value = c("motorway", "primary", "secondary", "tertiary",
                                     "residential", "living_street",
                                     "unclassified", "service", "footway")) |>
  osmdata::osmdata_sf()

river <- bbox |>
  osmdata::opq() |>
  osmdata::add_osm_feature(key = "waterway", value = "river") |>
  osmdata::osmdata_sf()

ggplot() +
  geom_sf(data = db$community_union, fill = NA) +
  geom_sf(data = streets$osm_lines, colour = "gray") +
  geom_sf(data = river$osm_lines, colour = "skyblue") +
  geom_sf(data = db$fude, aes(fill = farmer, colour = farmer), alpha = .5) +
  geom_sf(data = farm, aes(colour = farmer)) +
  geom_sf(data = farm_radius, aes(colour = farmer), linewidth = .3, fill = NA) +
  theme_void()
```

<img src="man/figures/README-sample-1.png" width="100%" />

``` r

library(ggmapinset)
library(ggrepel)

inset1 <- configure_inset(
    centre = sf::st_geometry(farm)[farm$farmer == "F"],
    scale = 3,
    translation = c(-4, 1),
    radius = 1, units = "km"
  )
inset2 <- configure_inset(
    centre = sf::st_geometry(farm)[farm$farmer == "E"],
    scale = 3,
    translation = c(4, -3),
    radius = 1, units = "km"
  )

farm$x <- sf::st_coordinates(farm)[, 1]
farm$y <- sf::st_coordinates(farm)[, 2]

ggplot(data = db$fude) +
  geom_sf(data = streets$osm_lines, colour = "gray") +
  geom_sf(data = river$osm_lines, colour = "skyblue") +
  geom_sf(aes(fill = farmer, colour = farmer), alpha = .5) +
  geom_sf(data = farm, aes(colour = farmer)) +
  geom_text_repel(data = farm,
                  aes(x = x, y = y, label = farmer),
                  nudge_x = c(.02, .02, .02, -.01, .02, -.012),
                  nudge_y = c(.01, 0, -.005, -.005, .01, -.005),
                  min.segment.length = 0,
                  segment.color = "black",
                  size = 3,
                  family = "Helvetica") +
  geom_sf_inset(data = streets$osm_lines, colour = "gray", map_base = "none", inset = inset1) +
  geom_sf_inset(data = river$osm_lines, colour = "skyblue", map_base = "none", inset = inset1) +
  geom_sf_inset(aes(fill = farmer, colour = farmer), alpha = .5, map_base = "normal", inset = inset1) +
  geom_inset_frame(inset = inset1) +
  geom_sf_inset(data = streets$osm_lines, colour = "gray", map_base = "none", inset = inset2) +
  geom_sf_inset(data = river$osm_lines, colour = "skyblue", map_base = "none", inset = inset2) +
  geom_sf_inset(aes(fill = farmer, colour = farmer), alpha = .5, map_base = "normal", inset = inset2) +
  geom_inset_frame(inset = inset2) +
  theme_void() +
  theme(legend.position = "none")
```

<img src="man/figures/README-sample-2.png" width="100%" />
