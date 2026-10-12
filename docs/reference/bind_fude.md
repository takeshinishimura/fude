# Bind multiple Fude Polygon data objects

`bind_fude()` combines multiple Fude Polygon data objects by binding
elements with the same names across inputs. It can also be used on
objects that have already been combined by
[`combine_fude()`](https://takeshinishimura.github.io/fude/reference/combine_fude.md).

## Usage

``` r
bind_fude(...)
```

## Arguments

- ...:

  Two or more Fude Polygon data objects to combine. Named elements that
  appear in multiple inputs are row-bound into a single
  [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) object.

## Value

A named list of
[`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html) objects.

## See also

[`combine_fude()`](https://takeshinishimura.github.io/fude/reference/combine_fude.md)

## Examples

``` r
path <- system.file("extdata", "castle.zip", package = "fude")
d1 <- read_fude(path, quiet = TRUE)
d2 <- read_fude(path, quiet = TRUE)
bind_fude(d1, d2)
#> Error in dplyr::bind_rows(relevant_dbs): Argument 1 must be a data frame or a named atomic vector.
```
