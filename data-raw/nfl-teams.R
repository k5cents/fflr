## code to prepare `nfl_teams` dataset goes here
dat <- try_json(
  url = "https://fantasy.espn.com/apis/v3/games/ffl/seasons/2021",
  query = list(view = "proTeamSchedules_wl")
)

nfl_teams <- data.frame(
  id = dat$settings$proTeams$id,
  abbrev = factor(
    x = dat$settings$proTeams$abbrev,
    levels = dat$settings$proTeams$abbrev[order(dat$settings$proTeams$id)]
  ),
  location = dat$settings$proTeams$location,
  name = dat$settings$proTeams$name,
  byeWeek = dat$settings$proTeams$byeWeek,
  conference = dat$settings$proTeams$universeId
)

nfl_teams$name[nfl_teams$name == ""] <- NA
nfl_teams$location[nfl_teams$location == ""] <- NA
nfl_teams$conference[nfl_teams$conference == 0] <- NA
nfl_teams$conference[nfl_teams$conference == 1] <- "AFC"
nfl_teams$conference[nfl_teams$conference == 2] <- "NFC"
nfl_teams <- as_tibble(nfl_teams[order(nfl_teams$id), ])
names(nfl_teams)[1] <- "proTeamId"

usethis::use_data(nfl_teams, overwrite = TRUE)
