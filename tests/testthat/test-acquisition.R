test_that("player acquisition", {
  a <- player_acquire(leagueId = "42654852")
  skip_if(nrow(a) == 0)
  expect_type(a, "list")
  expect_true("acquisitionType" %in% names(a[[1]]))
})

test_that("player acquisition errors on historu", {
  expect_error(
    object = player_acquire(
      leagueId = "42654852",
      leagueHistory = TRUE
    )
  )
})
