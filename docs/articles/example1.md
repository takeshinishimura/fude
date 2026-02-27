# Using \`gghighlight\` package

## Using `gghighlight` package

``` r
library(dplyr)
library(ggplot2)
library(gghighlight)

db <- combine_fude(d, b, city = "西条", kcity = "丹原|田野")

ggplot() +
  geom_sf(data = db$rcom, aes(fill = rcom_name), alpha = 0) +
  geom_sf(data = db$fude, aes(fill = rcom_name), linewidth = 0) +
  gghighlight() +
  facet_wrap(~ rcom_name) +
  theme_void() +
  theme(
    legend.position = "none",
    text = element_text(family = "Hiragino Sans")
  )
```

![](example1_files/figure-html/facet_wrap_saijo-1.png)

**出典**：農林水産省「筆ポリゴンデータ（2025年度公開）」および「農業集落境界データ（2020年度）」を加工して作成。

``` r
ggplot(data = db$fude, aes(x = a, fill = land_type_jp)) +
  geom_histogram(position = "identity", alpha = .5) +
  labs(x = "面積（a）",
       y = "頻度") +
  facet_wrap(~ rcom_name) +
  labs(fill = "耕地の種類") +
  theme_minimal() +
  theme(text = element_text(family = "Hiragino Sans"))
```

![](example1_files/figure-html/facet_wrap_saijo_hist-1.png)
