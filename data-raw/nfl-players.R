## code to prepare `players` dataset goes here
library(tidyverse)
library(lubridate)
# library(fflr) # loaded via devtools::load_all()

nfl_players <- list_players(
  sort = "ROST",
  status = "ALL",
  limit = NULL
)

nfl_players <- nfl_players[, 3:7]

out_players <- filter(nfl_players, defaultPosition != "D/ST")
out <- rep(list(NULL), nrow(out_players))
pb <- txtProgressBar(max = nrow(out_players), style = 3)
for (i in seq_along(out_players$id)) {
  if (is.na(out_players$defaultPosition[i])) {
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

def_players <- filter(nfl_players, defaultPosition == "D/ST")

nfl_players <- select(nfl_players, id, proTeam, defaultPosition)
zzz <- inner_join(nfl_players, out_players, by = "id")
zzz <- relocate(zzz, proTeam, defaultPosition, .after = lastName)

nfl_players <- bind_rows(zzz, def_players)
# nfl_players <- select(nfl_players, -birthPlace, -draftSelection)
# `player_info()` drops null fields, so column order follows whichever player
# came back first; pin it to the order documented in `R/data.R`
nfl_players <- relocate(nfl_players, debutYear, .before = draftSelection)
names(nfl_players)[1] <- "playerId"
usethis::use_data(nfl_players, overwrite = TRUE, version = 2)
readr::write_csv(nfl_players, "data-raw/nfl_players.csv", na = "")
