# Practical mapping examples with MAFF data

## Mapping MAFF data

Read data from the MAFF database
[地域の農業を見て・知って・活かすDB](https://www.maff.go.jp/j/tokei/census/shuraku_data/).

``` r
library(dplyr)
library(sf)
library(ggplot2)

b1 <- get_boundary(d, path = "~", boundary_type = 1, quiet = TRUE)
b2 <- get_boundary(d, path = "~", boundary_type = 2, quiet = TRUE)
b3 <- get_boundary(d, path = "~", boundary_type = 3, quiet = TRUE)

m1 <- read_ikasudb(b1, "~/IA0001_2023_2020_38.xlsx")
m2 <- read_ikasudb(b2, "~/IA0001_2023_2020_38.xlsx")
m3 <- read_ikasudb(b3, "~/IA0001_2023_2020_38.xlsx")

m1$地域類型1次分類 <- factor(m1$地域類型1次分類, levels = sort(unique(na.omit(m1$地域類型1次分類))))
m2$地域類型1次分類 <- factor(m2$地域類型1次分類, levels = sort(unique(na.omit(m2$地域類型1次分類))))
m3$地域類型1次分類 <- factor(m3$地域類型1次分類, levels = sort(unique(na.omit(m3$地域類型1次分類))))

ggplot() +
  geom_sf(data = m1, aes(fill = 地域類型1次分類), alpha = .8) +
  theme_void() +
  theme(text = element_text(family = "Hiragino Sans"))
```

![](example4_files/figure-html/ehime1-1.png)

**出典**: 農林水産省「農業集落境界データ（2020年度）」を加工して作成。

``` r
ggplot() +
  geom_sf(data = m2, aes(fill = 地域類型1次分類), alpha = .8) +
  theme_void() +
  theme(text = element_text(family = "Hiragino Sans"))
```

![](example4_files/figure-html/ehime2-1.png)

**出典**: 農林水産省「農業集落境界データ（2020年度）」を加工して作成。

``` r
ggplot() +
  geom_sf(data = m3, aes(fill = 地域類型1次分類), alpha = .8) +
  theme_void() +
  theme(text = element_text(family = "Hiragino Sans"))
```

![](example4_files/figure-html/ehime3-1.png)

**出典**: 農林水産省「農業集落境界データ（2020年度）」を加工して作成。

``` r
m1 <- read_ikasudb(b1, "~/SA1066_2020_2020_38.xlsx")
m2 <- read_ikasudb(b2, "~/SA1066_2020_2020_38.xlsx")
m3 <- read_ikasudb(b3, "~/SA1066_2020_2020_38.xlsx")

ggplot() +
  geom_sf(data = m1, aes(fill = `類別作付（栽培）面積_果樹類`)) +
  scale_fill_gradient(
    low  = "white",
    high = "darkorange",
    na.value = "grey90"
  ) +
  theme_void() +
  theme(text = element_text(family = "Hiragino Sans"))
```

![](example4_files/figure-html/ehime4-1.png)

**出典**: 農林水産省「農業集落境界データ（2020年度）」を加工して作成。

``` r
ggplot() +
  geom_sf(data = m2, aes(fill = `類別作付（栽培）面積_果樹類`)) +
  scale_fill_gradient(
    low  = "white",
    high = "darkorange",
    na.value = "grey90"
  ) +
  theme_void() +
  theme(text = element_text(family = "Hiragino Sans"))
```

![](example4_files/figure-html/ehime5-1.png)

**出典**: 農林水産省「農業集落境界データ（2020年度）」を加工して作成。

``` r
ggplot() +
  geom_sf(data = m3, aes(fill = `類別作付（栽培）面積_果樹類`)) +
  scale_fill_gradient(
    low  = "white",
    high = "darkorange",
    na.value = "grey90"
  ) +
  theme_void() +
  theme(text = element_text(family = "Hiragino Sans"))
```

![](example4_files/figure-html/ehime6-1.png)

**出典**: 農林水産省「農業集落境界データ（2020年度）」を加工して作成。
