# Motivation of this package

## Old format of Fude Polygon data

The Fude Polygon data published by MAFF on
<https://open.fude.maff.go.jp> for the years 2021 and 2022 is in GeoJSON
format. These datasets include local government codes but lack the `key`
column, which identifies geographical locations such as municipalities
or communities. Relying solely on the 6-digit local government codes
(the `local_government_cd` column) can be confusing, as most users are
not familiar with them. Therefore, this package aims to enhance
user-friendliness by converting these numeric codes into readable
Japanese geographical names.

``` r

library(fude)

d0 <- read_fude("~/2022_38.zip", quiet = TRUE)
names(d0)
```

    ##  [1] "2022_382019" "2022_382027" "2022_382035" "2022_382043" "2022_382051"
    ##  [6] "2022_382060" "2022_382078" "2022_382108" "2022_382132" "2022_382141"
    ## [11] "2022_382159" "2022_383562" "2022_383864" "2022_384011" "2022_384020"
    ## [16] "2022_384224" "2022_384429" "2022_384844" "2022_384887" "2022_385069"

``` r

names(d0[[1]])
```

    ##  [1] "polygon_uuid"           "land_type"              "issue_year"            
    ##  [4] "edit_year"              "history"                "last_polygon_uuid"     
    ##  [7] "prev_last_polygon_uuid" "local_government_cd"    "point_lng"             
    ## [10] "point_lat"              "geometry"

### List the contents of Fude Polygon data

``` r

ls_fude(d0)
```

    ## # A tibble: 20 × 7
    ##    name     issue_year local_government_cd     n pref_name city_name city_romaji
    ##    <chr>         <int> <chr>               <int> <chr>     <chr>     <chr>      
    ##  1 2022_38…       2022 382019              72045 愛媛県    松山市    Matsuyama-…
    ##  2 2022_38…       2022 382027              43396 愛媛県    今治市    Imabari-shi
    ##  3 2022_38…       2022 382035              61683 愛媛県    宇和島市  Uwajima-shi
    ##  4 2022_38…       2022 382043              37753 愛媛県    八幡浜市  Yawatahama…
    ##  5 2022_38…       2022 382051              15734 愛媛県    新居浜市  Niihama-shi
    ##  6 2022_38…       2022 382060              63244 愛媛県    西条市    Saijo-shi  
    ##  7 2022_38…       2022 382078              37570 愛媛県    大洲市    Ozu-shi    
    ##  8 2022_38…       2022 382108              33302 愛媛県    伊予市    Iyo-shi    
    ##  9 2022_38…       2022 382132              34781 愛媛県    四国中央市…… Shikokuchu…
    ## 10 2022_38…       2022 382141              73676 愛媛県    西予市    Seiyo-shi  
    ## 11 2022_38…       2022 382159              24235 愛媛県    東温市    Toon-shi   
    ## 12 2022_38…       2022 383562               2195 愛媛県    上島町    Kamijima-c…
    ## 13 2022_38…       2022 383864              22823 愛媛県    久万高原町…… Kumakogen-…
    ## 14 2022_38…       2022 384011               8634 愛媛県    松前町    Matsumae-c…
    ## 15 2022_38…       2022 384020               7042 愛媛県    砥部町    Tobe-cho   
    ## 16 2022_38…       2022 384224              27131 愛媛県    内子町    Uchiko-cho 
    ## 17 2022_38…       2022 384429              23429 愛媛県    伊方町    Ikata-cho  
    ## 18 2022_38…       2022 384844               9089 愛媛県    松野町    Matsuno-cho
    ## 19 2022_38…       2022 384887              16550 愛媛県    鬼北町    Kihoku-cho 
    ## 20 2022_38…       2022 385069              22931 愛媛県    愛南町    Ainan-cho

### Rename the local government code

**Note:** This feature is available only for data obtained from GeoJSON.

You can convert local government codes into Japanese municipality names
for easier data management.

``` r

d1 <- rename_fude(d0)
names(d1)
```

    ##  [1] "2022_松山市"     "2022_今治市"     "2022_宇和島市"   "2022_八幡浜市"  
    ##  [5] "2022_新居浜市"   "2022_西条市"     "2022_大洲市"     "2022_伊予市"    
    ##  [9] "2022_四国中央市" "2022_西予市"     "2022_東温市"     "2022_上島町"    
    ## [13] "2022_久万高原町" "2022_松前町"     "2022_砥部町"     "2022_内子町"    
    ## [17] "2022_伊方町"     "2022_松野町"     "2022_鬼北町"     "2022_愛南町"

You can also rename the columns to Romaji instead of Japanese.

``` r

d2 <- d0 |>
  rename_fude(suffix = TRUE, romaji = "title", quiet = FALSE)
```

    ## 2022_382019 -> 2022_Matsuyama-shi
    ## 2022_382027 -> 2022_Imabari-shi
    ## 2022_382035 -> 2022_Uwajima-shi
    ## 2022_382043 -> 2022_Yawatahama-shi
    ## 2022_382051 -> 2022_Niihama-shi
    ## 2022_382060 -> 2022_Saijo-shi
    ## 2022_382078 -> 2022_Ozu-shi
    ## 2022_382108 -> 2022_Iyo-shi
    ## 2022_382132 -> 2022_Shikokuchuo-shi
    ## 2022_382141 -> 2022_Seiyo-shi
    ## 2022_382159 -> 2022_Toon-shi
    ## 2022_383562 -> 2022_Kamijima-cho
    ## 2022_383864 -> 2022_Kumakogen-cho
    ## 2022_384011 -> 2022_Matsumae-cho
    ## 2022_384020 -> 2022_Tobe-cho
    ## 2022_384224 -> 2022_Uchiko-cho
    ## 2022_384429 -> 2022_Ikata-cho
    ## 2022_384844 -> 2022_Matsuno-cho
    ## 2022_384887 -> 2022_Kihoku-cho
    ## 2022_385069 -> 2022_Ainan-cho

## New format of Fude Polygon data

Since 2024, the Fude Polygon data published by MAFF
<https://www.maff.go.jp/j/tokei/census/shuraku_data/2025/mb/> is
provided in FlatGeobuf format. This new format includes a `key` column
that identifies municipalities and communities. However, it does not
include the corresponding Japanese geographical names. Because the `key`
is merely a 10-digit number, users cannot intuitively identify locations
without mapping them to proper Japanese names.

``` r

dn <- read_fude("~/MB0001_2026_2025_38.zip.001", quiet = TRUE)
names(dn)
```

    ## [1] "MB0001_2026_2025_38"

``` r

names(dn[[1]])
```

    ## [1] "polygon_uuid" "land_type"    "issue_year"   "point_lng"    "point_lat"   
    ## [6] "key"          "geometry"

### List the contents of Fude Polygon data

``` r

ls_fude(dn)
```

    ## # A tibble: 20 × 7
    ##    name     issue_year local_government_cd     n pref_name city_name city_romaji
    ##    <chr>         <dbl> <chr>               <int> <chr>     <chr>     <chr>      
    ##  1 MB0001_…       2026 382019              70801 愛媛県    松山市    Matsuyama-…
    ##  2 MB0001_…       2026 382027              43883 愛媛県    今治市    Imabari-shi
    ##  3 MB0001_…       2026 382035              61431 愛媛県    宇和島市  Uwajima-shi
    ##  4 MB0001_…       2026 382043              37612 愛媛県    八幡浜市  Yawatahama…
    ##  5 MB0001_…       2026 382051              15174 愛媛県    新居浜市  Niihama-shi
    ##  6 MB0001_…       2026 382060              60917 愛媛県    西条市    Saijo-shi  
    ##  7 MB0001_…       2026 382078              37354 愛媛県    大洲市    Ozu-shi    
    ##  8 MB0001_…       2026 382108              28586 愛媛県    伊予市    Iyo-shi    
    ##  9 MB0001_…       2026 382132              34238 愛媛県    四国中央市…… Shikokuchu…
    ## 10 MB0001_…       2026 382141              73033 愛媛県    西予市    Seiyo-shi  
    ## 11 MB0001_…       2026 382159              17511 愛媛県    東温市    Toon-shi   
    ## 12 MB0001_…       2026 383562               2200 愛媛県    上島町    Kamijima-c…
    ## 13 MB0001_…       2026 383864              17504 愛媛県    久万高原町…… Kumakogen-…
    ## 14 MB0001_…       2026 384011               7228 愛媛県    松前町    Matsumae-c…
    ## 15 MB0001_…       2026 384020               5867 愛媛県    砥部町    Tobe-cho   
    ## 16 MB0001_…       2026 384224              27261 愛媛県    内子町    Uchiko-cho 
    ## 17 MB0001_…       2026 384429              23217 愛媛県    伊方町    Ikata-cho  
    ## 18 MB0001_…       2026 384844               9017 愛媛県    松野町    Matsuno-cho
    ## 19 MB0001_…       2026 384887              16607 愛媛県    鬼北町    Kihoku-cho 
    ## 20 MB0001_…       2026 385069              22847 愛媛県    愛南町    Ainan-cho

### Combination with agricultural community boundaries

Combining Fude Polygons with agricultural community boundary data
provides deeper geographical insights and makes the data much easier to
work with.

``` r

b <- get_boundary(d0, path = "~", quiet = TRUE)
b
```

    ## $MA0001_2025_2025_38
    ## Simple feature collection with 3302 features and 18 fields
    ## Geometry type: MULTIPOLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.0123 ymin: 32.88498 xmax: 133.6928 ymax: 34.30165
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 3,302 × 19
    ##    key        pref  city  kcity rcom  pref_name city_name kcity_name rcom_name
    ##  * <chr>      <chr> <chr> <chr> <chr> <fct>     <fct>     <fct>      <fct>    
    ##  1 3820101001 38    201   01    001   愛媛県    松山市    松山市     土居田   
    ##  2 3820101002 38    201   01    002   愛媛県    松山市    松山市     針田     
    ##  3 3820101003 38    201   01    003   愛媛県    松山市    松山市     小栗第１ 
    ##  4 3820101004 38    201   01    004   愛媛県    松山市    松山市     小栗第２ 
    ##  5 3820101005 38    201   01    005   愛媛県    松山市    松山市     小栗第３ 
    ##  6 3820101006 38    201   01    006   愛媛県    松山市    松山市     藤原第１ 
    ##  7 3820101007 38    201   01    007   愛媛県    松山市    松山市     藤原第２ 
    ##  8 3820101008 38    201   01    008   愛媛県    松山市    松山市     竹原東   
    ##  9 3820101009 38    201   01    009   愛媛県    松山市    松山市     竹原西   
    ## 10 3820101010 38    201   01    010   愛媛県    松山市    松山市     生石南   
    ## # ℹ 3,292 more rows
    ## # ℹ 10 more variables: pref_kana <fct>, city_kana <fct>, rcom_kana <fct>,
    ## #   pref_romaji <fct>, city_romaji <fct>, rcom_romaji <fct>, hinintei <dbl>,
    ## #   geometry <MULTIPOLYGON [°]>, boundary_data_year <dbl>, rcom_year <dbl>

``` r

db <- d0 |>
  lapply(sf::st_transform, crs = sf::st_crs(b[[1]])) |>
  combine_fude(b, city = "松山市", rcom = "由良|北浦|鷲ケ巣|門田|馬磯|泊|御手洗|船越")
db
```

    ## $fude
    ## Simple feature collection with 1538 features and 30 fields
    ## Active geometry column: geometry
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.6565 ymin: 33.87055 xmax: 132.6991 ymax: 33.92544
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 1,538 × 32
    ##    polygon_uuid         land_type issue_year edit_year history last_polygon_uuid
    ##  * <chr>                    <int>      <int>     <int> <chr>   <chr>            
    ##  1 c5a5b237-01cc-4d32-…       200       2022      2020 "[{\"筆… c80f701f-4ca5-48…
    ##  2 8085bc47-9af5-440f-…       200       2022      2020 "[{\"筆… cce37bbc-e522-4c…
    ##  3 d6e1994a-b436-482c-…       200       2022      2020 "[{\"筆… fa8d6431-9ca9-41…
    ##  4 f42c22ba-5f7d-4e86-…       200       2022      2020 "[{\"筆… c356c07b-e3da-46…
    ##  5 ff31af8a-edfc-4da7-…       200       2022      2020 "[{\"筆… a8a45f04-cac6-4f…
    ##  6 2ae34692-c4ba-4996-…       200       2022      2020 "[{\"筆… 07265986-d506-4d…
    ##  7 ef0218f5-f251-4176-…       200       2022      2020 "[{\"筆… 4ba88c25-6740-45…
    ##  8 04b7cdf4-d889-45c2-…       200       2022      2020 "[{\"筆… 6c1764da-3269-4f…
    ##  9 0d7a53c5-7ccf-4307-…       200       2022      2020 "[{\"筆… c61e71a0-69bc-4c…
    ## 10 26920da0-b63e-4994-…       200       2022      2020 "[{\"筆… f0c1a613-174c-42…
    ## # ℹ 1,528 more rows
    ## # ℹ 26 more variables: prev_last_polygon_uuid <chr>, local_government_cd <chr>,
    ## #   point_lng <dbl>, point_lat <dbl>, geometry <POLYGON [°]>, key <chr>,
    ## #   pref <chr>, city <chr>, kcity <chr>, rcom <chr>, pref_name <fct>,
    ## #   city_name <fct>, kcity_name <fct>, rcom_name <fct>, pref_kana <fct>,
    ## #   city_kana <fct>, rcom_kana <fct>, pref_romaji <fct>, city_romaji <fct>,
    ## #   rcom_romaji <fct>, hinintei <dbl>, boundary_data_year <dbl>, …
    ## 
    ## $fude_split
    ## Simple feature collection with 1618 features and 30 fields
    ## Active geometry column: geometry
    ## Geometry type: GEOMETRY
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.6565 ymin: 33.87055 xmax: 132.6991 ymax: 33.92544
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 1,618 × 32
    ##    polygon_uuid         land_type issue_year edit_year history last_polygon_uuid
    ##  * <chr>                    <int>      <int>     <int> <chr>   <chr>            
    ##  1 5cda9fe7-c019-4d24-…       200       2022      2020 "[{\"筆… 666c8a6e-87ff-49…
    ##  2 9a09f709-5af7-4401-…       200       2022      2020 "[{\"筆… 1c183f1b-bd2c-4e…
    ##  3 d8c4e75e-8e6d-4460-…       200       2022      2020 "[{\"筆… 1e32423c-d1f8-49…
    ##  4 de639667-5335-41a6-…       200       2022      2020 "[{\"筆… ed224e72-1acb-42…
    ##  5 835956a9-1250-46ae-…       200       2022      2020 "[{\"筆… 281ebcce-7bd9-48…
    ##  6 f4863aa6-50e9-496f-…       200       2022      2020 "[{\"筆… 2febecbf-7947-44…
    ##  7 dc3cf0d4-e138-42b7-…       200       2022      2020 "[{\"筆… 85d0a750-02fd-49…
    ##  8 d38fb51a-61a3-4bc2-…       200       2022      2020 "[{\"筆… e4e374a0-d2d6-45…
    ##  9 52231c0d-ead7-48cc-…       200       2022      2020 "[{\"筆… 57b0122a-6a53-4a…
    ## 10 d01cacfd-4094-48f4-…       200       2022      2020 "[{\"筆… 9879255f-4036-4a…
    ## # ℹ 1,608 more rows
    ## # ℹ 26 more variables: prev_last_polygon_uuid <chr>, local_government_cd <chr>,
    ## #   point_lng <dbl>, point_lat <dbl>, key <chr>, pref <chr>, city <chr>,
    ## #   kcity <chr>, rcom <chr>, pref_name <fct>, city_name <fct>,
    ## #   kcity_name <fct>, rcom_name <fct>, pref_kana <fct>, city_kana <fct>,
    ## #   rcom_kana <fct>, pref_romaji <fct>, city_romaji <fct>, rcom_romaji <fct>,
    ## #   hinintei <dbl>, boundary_data_year <dbl>, rcom_year <dbl>, x <dbl>, …
    ## 
    ## $rcom
    ## Simple feature collection with 8 features and 20 fields
    ## Geometry type: MULTIPOLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.653 ymin: 33.87033 xmax: 132.7028 ymax: 33.92698
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 8 × 21
    ##   key        pref  city  kcity rcom  pref_name city_name kcity_name rcom_name
    ## * <chr>      <chr> <chr> <chr> <chr> <fct>     <fct>     <fct>      <fct>    
    ## 1 3820102001 38    201   02    001   愛媛県    松山市    興居島村   御手洗   
    ## 2 3820102002 38    201   02    002   愛媛県    松山市    興居島村   泊       
    ## 3 3820102003 38    201   02    003   愛媛県    松山市    興居島村   船越     
    ## 4 3820102005 38    201   02    005   愛媛県    松山市    興居島村   鷲ケ巣   
    ## 5 3820102006 38    201   02    006   愛媛県    松山市    興居島村   由良     
    ## 6 3820102007 38    201   02    007   愛媛県    松山市    興居島村   北浦     
    ## 7 3820102008 38    201   02    008   愛媛県    松山市    興居島村   門田     
    ## 8 3820102009 38    201   02    009   愛媛県    松山市    興居島村   馬磯     
    ## # ℹ 12 more variables: pref_kana <fct>, city_kana <fct>, rcom_kana <fct>,
    ## #   pref_romaji <fct>, city_romaji <fct>, rcom_romaji <fct>, hinintei <dbl>,
    ## #   geometry <MULTIPOLYGON [°]>, boundary_data_year <dbl>, rcom_year <dbl>,
    ## #   x <dbl>, y <dbl>
    ## 
    ## $rcom_union
    ## Simple feature collection with 1 feature and 2 fields
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.653 ymin: 33.87033 xmax: 132.7028 ymax: 33.92698
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 1 × 3
    ##                                                             geometry     x     y
    ## *                                                      <POLYGON [°]> <dbl> <dbl>
    ## 1 ((132.6829 33.90231, 132.6832 33.9023, 132.6832 33.90231, 132.683…  133.  33.9
    ## 
    ## $kcity
    ## Simple feature collection with 285 features and 11 fields
    ## Geometry type: GEOMETRY
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.0123 ymin: 32.88498 xmax: 133.6928 ymax: 34.30165
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 285 × 12
    ##    key        pref_name city_name kcity_name pref_kana  city_kana  pref_romaji
    ##  * <chr>      <chr>     <chr>     <chr>      <chr>      <chr>      <chr>      
    ##  1 3820101000 愛媛県    松山市    松山市     えひめけん まつやまし Ehime      
    ##  2 3820102000 愛媛県    松山市    興居島村   えひめけん まつやまし Ehime      
    ##  3 3820103000 愛媛県    松山市    余土村     えひめけん まつやまし Ehime      
    ##  4 3820104000 愛媛県    松山市    浮穴村     えひめけん まつやまし Ehime      
    ##  5 3820105000 愛媛県    松山市    久米村     えひめけん まつやまし Ehime      
    ##  6 3820106000 愛媛県    松山市    湯山村     えひめけん まつやまし Ehime      
    ##  7 3820107000 愛媛県    松山市    五明村     えひめけん まつやまし Ehime      
    ##  8 3820108000 愛媛県    松山市    伊台村     えひめけん まつやまし Ehime      
    ##  9 3820109000 愛媛県    松山市    小野村     えひめけん まつやまし Ehime      
    ## 10 3820110000 愛媛県    松山市    石井村     えひめけん まつやまし Ehime      
    ## # ℹ 275 more rows
    ## # ℹ 5 more variables: city_romaji <chr>, geometry <GEOMETRY [°]>, fill <fct>,
    ## #   x <dbl>, y <dbl>
    ## 
    ## $city
    ## Simple feature collection with 20 features and 10 fields
    ## Geometry type: GEOMETRY
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.0123 ymin: 32.88498 xmax: 133.6928 ymax: 34.30165
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 20 × 11
    ##    key        pref_name city_name  pref_kana  city_kana  pref_romaji city_romaji
    ##  * <chr>      <chr>     <chr>      <chr>      <chr>      <chr>       <chr>      
    ##  1 3820100000 愛媛県    松山市     えひめけん まつやまし Ehime       Matsuyama-…
    ##  2 3820200000 愛媛県    今治市     えひめけん いまばりし Ehime       Imabari-shi
    ##  3 3820300000 愛媛県    宇和島市   えひめけん うわじまし Ehime       Uwajima-shi
    ##  4 3820400000 愛媛県    八幡浜市   えひめけん やわたはまし…… Ehime       Yawatahama…
    ##  5 3820500000 愛媛県    新居浜市   えひめけん にいはまし Ehime       Niihama-shi
    ##  6 3820600000 愛媛県    西条市     えひめけん さいじょうし…… Ehime       Saijo-shi  
    ##  7 3820700000 愛媛県    大洲市     えひめけん おおずし   Ehime       Ozu-shi    
    ##  8 3821000000 愛媛県    伊予市     えひめけん いよし     Ehime       Iyo-shi    
    ##  9 3821300000 愛媛県    四国中央市 えひめけん しこくちゅうおうし… Ehime       Shikokuchu…
    ## 10 3821400000 愛媛県    西予市     えひめけん せいよし   Ehime       Seiyo-shi  
    ## 11 3821500000 愛媛県    東温市     えひめけん とうおんし Ehime       Toon-shi   
    ## 12 3835600000 愛媛県    上島町     えひめけん かみじまちょう…… Ehime       Kamijima-c…
    ## 13 3838600000 愛媛県    久万高原町 えひめけん くまこうげんちょう… Ehime       Kumakogen-…
    ## 14 3840100000 愛媛県    松前町     えひめけん まさきちょう…… Ehime       Matsumae-c…
    ## 15 3840200000 愛媛県    砥部町     えひめけん とべちょう Ehime       Tobe-cho   
    ## 16 3842200000 愛媛県    内子町     えひめけん うちこちょう…… Ehime       Uchiko-cho 
    ## 17 3844200000 愛媛県    伊方町     えひめけん いかたちょう…… Ehime       Ikata-cho  
    ## 18 3848400000 愛媛県    松野町     えひめけん まつのちょう…… Ehime       Matsuno-cho
    ## 19 3848800000 愛媛県    鬼北町     えひめけん きほくちょう…… Ehime       Kihoku-cho 
    ## 20 3850600000 愛媛県    愛南町     えひめけん あいなんちょう…… Ehime       Ainan-cho  
    ## # ℹ 4 more variables: geometry <GEOMETRY [°]>, fill <fct>, x <dbl>, y <dbl>
    ## 
    ## $pref
    ## Simple feature collection with 1 feature and 6 fields
    ## Geometry type: MULTIPOLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.0123 ymin: 32.88498 xmax: 133.6928 ymax: 34.30165
    ## Geodetic CRS:  JGD2000
    ##   pref pref_name  pref_kana pref_romaji                       geometry        x
    ## 1   38    愛媛県 えひめけん       Ehime MULTIPOLYGON (((132.3561 33... 132.8534
    ##          y
    ## 1 33.62537

``` r

dbn <- combine_fude(dn, b, city = "松山市", rcom = "由良|北浦|鷲ケ巣|門田|馬磯|泊|御手洗|船越")
dbn
```

    ## $fude
    ## Simple feature collection with 1566 features and 25 fields
    ## Active geometry column: geometry
    ## Geometry type: MULTIPOLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.6565 ymin: 33.87055 xmax: 132.6991 ymax: 33.92544
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 1,566 × 27
    ##    polygon_uuid                   land_type issue_year point_lng point_lat key  
    ##  * <chr>                              <dbl>      <dbl>     <dbl>     <dbl> <chr>
    ##  1 c718cdbf-b34c-43fd-8c55-14e4f…       200       2026      133.      33.9 3820…
    ##  2 d02ca439-0046-4ff1-a558-69799…       200       2026      133.      33.9 3820…
    ##  3 15d0099d-b5db-426b-9e9e-da960…       200       2026      133.      33.9 3820…
    ##  4 5c07ac7b-ad6c-4047-8c63-90ab3…       200       2026      133.      33.9 3820…
    ##  5 0f8df69b-8432-4b62-a384-c7cb3…       200       2026      133.      33.9 3820…
    ##  6 2b3274f7-5360-4f16-a5ff-b5df3…       200       2026      133.      33.9 3820…
    ##  7 d677ca15-f213-4ddc-b9d9-52118…       200       2026      133.      33.9 3820…
    ##  8 fe57e66b-964b-4fa6-8575-46c60…       200       2026      133.      33.9 3820…
    ##  9 2aeb9259-5354-4b6e-9224-2a21c…       200       2026      133.      33.9 3820…
    ## 10 bd6ea129-4750-4dce-801f-1ab95…       200       2026      133.      33.9 3820…
    ## # ℹ 1,556 more rows
    ## # ℹ 21 more variables: geometry <MULTIPOLYGON [°]>, pref <chr>, city <chr>,
    ## #   kcity <chr>, rcom <chr>, pref_name <fct>, city_name <fct>,
    ## #   kcity_name <fct>, rcom_name <fct>, pref_kana <fct>, city_kana <fct>,
    ## #   rcom_kana <fct>, pref_romaji <fct>, city_romaji <fct>, rcom_romaji <fct>,
    ## #   hinintei <dbl>, boundary_data_year <dbl>, rcom_year <dbl>, x <dbl>,
    ## #   y <dbl>, centroid <POINT [°]>
    ## 
    ## $rcom
    ## Simple feature collection with 8 features and 20 fields
    ## Geometry type: MULTIPOLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.653 ymin: 33.87033 xmax: 132.7028 ymax: 33.92698
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 8 × 21
    ##   key        pref  city  kcity rcom  pref_name city_name kcity_name rcom_name
    ## * <chr>      <chr> <chr> <chr> <chr> <fct>     <fct>     <fct>      <fct>    
    ## 1 3820102001 38    201   02    001   愛媛県    松山市    興居島村   御手洗   
    ## 2 3820102002 38    201   02    002   愛媛県    松山市    興居島村   泊       
    ## 3 3820102003 38    201   02    003   愛媛県    松山市    興居島村   船越     
    ## 4 3820102005 38    201   02    005   愛媛県    松山市    興居島村   鷲ケ巣   
    ## 5 3820102006 38    201   02    006   愛媛県    松山市    興居島村   由良     
    ## 6 3820102007 38    201   02    007   愛媛県    松山市    興居島村   北浦     
    ## 7 3820102008 38    201   02    008   愛媛県    松山市    興居島村   門田     
    ## 8 3820102009 38    201   02    009   愛媛県    松山市    興居島村   馬磯     
    ## # ℹ 12 more variables: pref_kana <fct>, city_kana <fct>, rcom_kana <fct>,
    ## #   pref_romaji <fct>, city_romaji <fct>, rcom_romaji <fct>, hinintei <dbl>,
    ## #   geometry <MULTIPOLYGON [°]>, boundary_data_year <dbl>, rcom_year <dbl>,
    ## #   x <dbl>, y <dbl>
    ## 
    ## $rcom_union
    ## Simple feature collection with 1 feature and 2 fields
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.653 ymin: 33.87033 xmax: 132.7028 ymax: 33.92698
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 1 × 3
    ##                                                             geometry     x     y
    ## *                                                      <POLYGON [°]> <dbl> <dbl>
    ## 1 ((132.6829 33.90231, 132.6832 33.9023, 132.6832 33.90231, 132.683…  133.  33.9
    ## 
    ## $kcity
    ## Simple feature collection with 285 features and 11 fields
    ## Geometry type: GEOMETRY
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.0123 ymin: 32.88498 xmax: 133.6928 ymax: 34.30165
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 285 × 12
    ##    key        pref_name city_name kcity_name pref_kana  city_kana  pref_romaji
    ##  * <chr>      <chr>     <chr>     <chr>      <chr>      <chr>      <chr>      
    ##  1 3820101000 愛媛県    松山市    松山市     えひめけん まつやまし Ehime      
    ##  2 3820102000 愛媛県    松山市    興居島村   えひめけん まつやまし Ehime      
    ##  3 3820103000 愛媛県    松山市    余土村     えひめけん まつやまし Ehime      
    ##  4 3820104000 愛媛県    松山市    浮穴村     えひめけん まつやまし Ehime      
    ##  5 3820105000 愛媛県    松山市    久米村     えひめけん まつやまし Ehime      
    ##  6 3820106000 愛媛県    松山市    湯山村     えひめけん まつやまし Ehime      
    ##  7 3820107000 愛媛県    松山市    五明村     えひめけん まつやまし Ehime      
    ##  8 3820108000 愛媛県    松山市    伊台村     えひめけん まつやまし Ehime      
    ##  9 3820109000 愛媛県    松山市    小野村     えひめけん まつやまし Ehime      
    ## 10 3820110000 愛媛県    松山市    石井村     えひめけん まつやまし Ehime      
    ## # ℹ 275 more rows
    ## # ℹ 5 more variables: city_romaji <chr>, geometry <GEOMETRY [°]>, fill <fct>,
    ## #   x <dbl>, y <dbl>
    ## 
    ## $city
    ## Simple feature collection with 20 features and 10 fields
    ## Geometry type: GEOMETRY
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.0123 ymin: 32.88498 xmax: 133.6928 ymax: 34.30165
    ## Geodetic CRS:  JGD2000
    ## # A tibble: 20 × 11
    ##    key        pref_name city_name  pref_kana  city_kana  pref_romaji city_romaji
    ##  * <chr>      <chr>     <chr>      <chr>      <chr>      <chr>       <chr>      
    ##  1 3820100000 愛媛県    松山市     えひめけん まつやまし Ehime       Matsuyama-…
    ##  2 3820200000 愛媛県    今治市     えひめけん いまばりし Ehime       Imabari-shi
    ##  3 3820300000 愛媛県    宇和島市   えひめけん うわじまし Ehime       Uwajima-shi
    ##  4 3820400000 愛媛県    八幡浜市   えひめけん やわたはまし…… Ehime       Yawatahama…
    ##  5 3820500000 愛媛県    新居浜市   えひめけん にいはまし Ehime       Niihama-shi
    ##  6 3820600000 愛媛県    西条市     えひめけん さいじょうし…… Ehime       Saijo-shi  
    ##  7 3820700000 愛媛県    大洲市     えひめけん おおずし   Ehime       Ozu-shi    
    ##  8 3821000000 愛媛県    伊予市     えひめけん いよし     Ehime       Iyo-shi    
    ##  9 3821300000 愛媛県    四国中央市 えひめけん しこくちゅうおうし… Ehime       Shikokuchu…
    ## 10 3821400000 愛媛県    西予市     えひめけん せいよし   Ehime       Seiyo-shi  
    ## 11 3821500000 愛媛県    東温市     えひめけん とうおんし Ehime       Toon-shi   
    ## 12 3835600000 愛媛県    上島町     えひめけん かみじまちょう…… Ehime       Kamijima-c…
    ## 13 3838600000 愛媛県    久万高原町 えひめけん くまこうげんちょう… Ehime       Kumakogen-…
    ## 14 3840100000 愛媛県    松前町     えひめけん まさきちょう…… Ehime       Matsumae-c…
    ## 15 3840200000 愛媛県    砥部町     えひめけん とべちょう Ehime       Tobe-cho   
    ## 16 3842200000 愛媛県    内子町     えひめけん うちこちょう…… Ehime       Uchiko-cho 
    ## 17 3844200000 愛媛県    伊方町     えひめけん いかたちょう…… Ehime       Ikata-cho  
    ## 18 3848400000 愛媛県    松野町     えひめけん まつのちょう…… Ehime       Matsuno-cho
    ## 19 3848800000 愛媛県    鬼北町     えひめけん きほくちょう…… Ehime       Kihoku-cho 
    ## 20 3850600000 愛媛県    愛南町     えひめけん あいなんちょう…… Ehime       Ainan-cho  
    ## # ℹ 4 more variables: geometry <GEOMETRY [°]>, fill <fct>, x <dbl>, y <dbl>
    ## 
    ## $pref
    ## Simple feature collection with 1 feature and 6 fields
    ## Geometry type: MULTIPOLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 132.0123 ymin: 32.88498 xmax: 133.6928 ymax: 34.30165
    ## Geodetic CRS:  JGD2000
    ##   pref pref_name  pref_kana pref_romaji                       geometry        x
    ## 1   38    愛媛県 えひめけん       Ehime MULTIPOLYGON (((132.3561 33... 132.8534
    ##          y
    ## 1 33.62537
