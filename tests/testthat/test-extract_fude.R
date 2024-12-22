test_that("extract_fude() works", {
  d <- lapply(
    list(
      "2022_261025" = data.frame(issue_year = 2022, polygon_uuid = NA, local_government_cd = "261025"),
      "2022_261033" = data.frame(issue_year = 2022, polygon_uuid = NA, local_government_cd = "261033"),
      "2021_261033" = data.frame(issue_year = 2021, polygon_uuid = NA, local_government_cd = "261033")
    ),
    function(df) {
      df$geometry <- sf::st_sfc(sf::st_point(c(0, 0)), crs = 4326)
      sf::st_as_sf(df)
    }
  )

  expect_match(unique(extract_fude(d, year = 2022)$local_government_cd)[1], "261025")
  expect_match(unique(extract_fude(d, year = 2021)$local_government_cd), "261033")
})
