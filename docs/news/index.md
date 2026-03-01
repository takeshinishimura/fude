# Changelog

## fude (development version)

- Added support for processing data without requiring the local
  government code to be pre-written.

- Renamed the `community` argument to `rcom` in several functions.

- Added `kcity_code_table` and `city_code_table`.

- Standardized column names to lowercase.

- Added support for reading data from the MAFF database
  “地域の農業を見て・知って・活かすDB”
  (<https://www.maff.go.jp/j/tokei/census/shuraku_data/>).

- Added the ability to combine with agricultural community boundary
  data.

## fude 0.3.7

CRAN release: 2024-12-22

- Added support for reading FlatGeobuf files in addition to GeoJSON
  files.
- Enabled handling of agricultural community boundary data without the
  need to load Fude polygons.
- Changed some names in the output list.

## fude 0.3.6

CRAN release: 2024-05-18

- Added columns for additional information on each farmland.

## fude 0.3.5

CRAN release: 2023-10-08

- Simplified the return value of
  [`combine_fude()`](https://takeshinishimura.github.io/fude/reference/combine_fude.md)
  by eliminating the reduced version of the object.

## fude 0.3.4

CRAN release: 2023-09-19

- Added support for polygon data that is not split.

## fude 0.3.3

CRAN release: 2023-08-18

- Added the ability to easily draw municipal boundaries.

## fude 0.3.2

- Improved the process of eliminating duplicate agricultural community
  names.

## fude 0.3.1

CRAN release: 2023-07-15

- Minor modifications due to elapsed time for samples being too long.

## fude 0.3.0

- Added the ability to combine with agricultural community boundary
  data.

## fude 0.2.0

CRAN release: 2023-06-14

- Improved accuracy of Roman renaming.

## fude 0.1.1

CRAN release: 2023-05-07

- Minor improvements.
- Initial CRAN release.

## fude 0.1.0

- Initial release.
