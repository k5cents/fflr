test_that("recent activity", {
  a <- recent_activity(
    leagueId = "42654852",
    seasonId = 2021,
    scoringPeriodId = 1
  )
  expect_s3_class(a, "data.frame")
  # ESPN returns extra fields to signed-in requests (`expirationDate`,
  # `teamActions`, `acceptedDate`) and omits `processDate` from some
  # unauthenticated responses, so only assert the columns always present
  expect_true(
    all(
      c(
        "bidAmount", "executionType", "id", "isActingAsTeamOwner",
        "isLeagueManager", "isPending", "items", "proposedDate",
        "scoringPeriodId", "skipTransactionCounters", "teamId", "type"
      ) %in% names(a)
    )
  )
  expect_type(a$items, "list")
  expect_s3_class(a$proposedDate, "POSIXt")
  for (d in c("processDate", "expirationDate", "acceptedDate")) {
    if (!is.null(a[[d]])) {
      expect_s3_class(a[[d]], "POSIXt")
    }
  }
})
