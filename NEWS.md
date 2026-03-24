# fude (development version)

* Reduced the number of packages listed in `Imports` and minimized optional package dependencies where possible.
* Improved handling of coordinate reference systems (CRS) to ensure consistent spatial operations.

# fude 0.4.0

* Added support for processing data without requiring the local government code to be pre-written.
* Renamed the `community` argument to `rcom` in several functions.
* Standardized column names to lowercase.
* Added support for reading data from the MAFF database (<https://www.maff.go.jp/j/tokei/census/shuraku_data/>).

# fude 0.3.7

* Added support for reading FlatGeobuf files in addition to GeoJSON files.
* Enabled handling of agricultural community boundary data without the need to load Fude polygons.
* Changed some names in the output list.

# fude 0.3.6

* Added columns for additional information on each farmland.

# fude 0.3.5

* Simplified the return value of `combine_fude()` by eliminating the reduced version of the object.

# fude 0.3.4

* Added support for polygon data that is not split.

# fude 0.3.3

* Added the ability to easily draw municipal boundaries.

# fude 0.3.2

* Improved the process of eliminating duplicate agricultural community names.

# fude 0.3.1

* Minor modifications due to elapsed time for samples being too long.

# fude 0.3.0

* Added the ability to combine with agricultural community boundary data.

# fude 0.2.0

* Improved accuracy of Roman renaming.

# fude 0.1.1

* Minor improvements.
* Initial CRAN release.

# fude 0.1.0

* Initial release.
