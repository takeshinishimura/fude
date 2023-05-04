test_that("extract_fude() works", {
  d <- list("2022_261025" = 1, "2022_261033" = 2, "2021_261033" = 3)

  expect_match(names(extract_fude(d, year = 2022))[1], "2022_261025")
  expect_match(names(extract_fude(d, year = 2021)), "2021_261033")
  expect_match(names(extract_fude(d, city = "261025")), "2022_261025")
  expect_match(names(extract_fude(d, city = "261033"))[2], "2021_261033")
  expect_match(names(extract_fude(d))[2], "2022_261033")
})
