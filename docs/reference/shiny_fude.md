# Prepare a Shiny Leaflet viewer for Fude Polygon data

`shiny_fude()` prepares a Shiny user interface and server function for
interactive visualization of Fude Polygon data with `leaflet` and `DT`.
The map supports polygon selection, optional agricultural community
boundary overlays, and a linked attribute table.

## Usage

``` r
shiny_fude(data, height = 1000, rcom = FALSE)
```

## Arguments

- data:

  A Fude Polygon data object, or a list containing `fude` and `rcom`
  elements. If `rcom = TRUE`, `data` must contain both polygon data in
  `data$fude` and agricultural community boundary data in `data$rcom`.

- height:

  Height of the map passed to
  [`leaflet::leafletOutput()`](https://rstudio.github.io/leaflet/reference/map-shiny.html).

- rcom:

  Logical. If `TRUE`, overlay agricultural community boundaries on the
  map.

## Value

A list with two elements: `ui`, a Shiny UI object, and `server`, a Shiny
server function.
