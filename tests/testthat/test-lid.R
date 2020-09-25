library(testthat)
library(fflr)

test_that("existing league ID can be retrieved", {
  options(lid = 252353)
  expect_message(set_lid(252353), "already")
})

test_that("existing league ID can be retrieved", {
  options(lid = NULL)
  expect_message(set_lid(252353), "^new")
})

rp <- path.expand("~/.Rprofile")
if (!requireNamespace("usethis", quietly = TRUE)) {
  test_that(".Rprofile not edited without 'usethis'", {
    expect_error(set_lid(252353, edit = TRUE))
  })
} else if (!file.exists(rp)) {
  test_that(".Rprofile is not created if exists", {
    set_lid(252353, edit = TRUE)
    expect_true(file.exists(rp))
  })
} else {
  test_that("", {
    options(lid = NULL)
    x <- set_lid(252353, edit = TRUE)
    expect_equal(x, 252353)
  })
}
