d <- jsonlite::fromJSON(
  txt = paste0(
    "https://fantasy.espn.com/apis/v3/games/ffl/seasons/", year,
    "?view=proTeamSchedules_wl"
  )
)

nfl_teams <- tibble(
  team = d$settings$proTeams$id,
  abbrev = factor(
    x = d$settings$proTeams$abbrev,
    levels = d$settings$proTeams$abbrev[order(d$settings$proTeams$id)]
  ),
  location = d$settings$proTeams$location,
  name = d$settings$proTeams$name,
  bye = d$settings$proTeams$byeWeek,
  conf = d$settings$proTeams$universeId
)

nfl_teams$name[nfl_teams$name == ""] <- NA
nfl_teams$location[nfl_teams$location == ""] <- NA
nfl_teams$conf[nfl_teams$conf == 0] <- NA
nfl_teams$conf[nfl_teams$conf == 1] <- "AFC"
nfl_teams$conf[nfl_teams$conf == 2] <- "NFC"
nfl_teams <- nfl_teams[order(nfl_teams$team), ]

usethis::use_data(nfl_teams, overwrite = TRUE)
