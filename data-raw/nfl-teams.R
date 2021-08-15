## code to prepare `nfl_teams` dataset goes here
d <- jsonlite::fromJSON(
  txt = paste0(
    "https://fantasy.espn.com/apis/v3/games/ffl/seasons/", 2021,
    "?view=proTeamSchedules_wl"
  )
)

nfl_teams <- data.frame(
  id = d$settings$proTeams$id,
  abbrev = factor(
    x = d$settings$proTeams$abbrev,
    levels = d$settings$proTeams$abbrev[order(d$settings$proTeams$id)]
  ),
  location = d$settings$proTeams$location,
  name = d$settings$proTeams$name,
  byeWeek = d$settings$proTeams$byeWeek,
  conference = d$settings$proTeams$universeId
)

nfl_teams$name[nfl_teams$name == ""] <- NA
nfl_teams$location[nfl_teams$location == ""] <- NA
nfl_teams$conference[nfl_teams$conference == 0] <- NA
nfl_teams$conference[nfl_teams$conference == 1] <- "AFC"
nfl_teams$conference[nfl_teams$conference == 2] <- "NFC"
nfl_teams <- nfl_teams[order(nfl_teams$id), ]

usethis::use_data(nfl_teams, overwrite = TRUE)

nfl_abb <- nfl_teams[, 1:2]
usethis::use_data(nfl_abb, internal = TRUE)
