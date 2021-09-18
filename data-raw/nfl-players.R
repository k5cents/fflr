## code to prepare `players` dataset goes here
library(tidyverse)
library(lubridate)
library(fflr)

nfl_players <- all_players(limit = NULL)[, 3:7]
out_players <- filter(nfl_players, defaultPositionId != "DS")
out <- rep(list(NULL), nrow(out_players))
pb <- txtProgressBar(max = nrow(out_players), style = 3)
for (i in seq_along(out_players$id)) {
  if (is.na(out_players$defaultPositionId[i])) {
    next()
  } else {
    out[[i]] <- player_info(out_players$id[i])
    out[[i]] <- map(out[[i]], ~ifelse(is.null(.), NA, .))
  }
  setTxtProgressBar(pb, i)
}

out_players <- map_df(out, tibble::as_tibble)
out_players$dateOfBirth <- as.Date(
  x = out_players$dateOfBirth,
  origin = "1970-01-01"
)

out_players <- select(out_players, -positionId)

def_players <- filter(nfl_players, defaultPositionId == "DS")

nfl_players <- select(nfl_players, id, proTeam, defaultPositionId)
zzz <- inner_join(nfl_players, out_players, by = "id")
zzz <- relocate(zzz, proTeam, defaultPositionId, .after = lastName)

nfl_players <- bind_rows(zzz, def_players)
nfl_players <- select(nfl_players, -birthPlace, -draftSelection)
names(nfl_players)[1] <- "playerId"
usethis::use_data(nfl_players, overwrite = TRUE)
