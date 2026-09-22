# a made-up `out_roster()` row for offline lineup tests
fake_player <- function(id, first, last, pos, proj, slot = "BE") {
  data.frame(
    seasonId = 2026L,
    scoringPeriodId = 10L,
    teamId = 1L,
    abbrev = factor("AAA"),
    lineupSlot = slot_abbrev(slot_unabbrev(slot)),
    playerId = id,
    firstName = first,
    lastName = last,
    proTeam = factor("FA"),
    position = factor(pos),
    injuryStatus = "A",
    projectedScore = proj,
    actualScore = NA_real_,
    percentStarted = NA_real_,
    percentOwned = NA_real_,
    percentChange = NA_real_,
    eligibleSlots = I(list(c(slot_unabbrev(pos), 20L, 21L)))
  )
}
