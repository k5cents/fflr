## code to prepare `players` dataset goes here
library(tidyverse)
library(lubridate)
library(fflr)

nfl_players <- all_players()[, 3:7]
out_players <- filter(nfl_players, pos != "DS")
out <- rep(list(NULL), nrow(out_players))
pb <- txtProgressBar(max = nrow(out_players), style = 3)
for (i in seq_along(out_players$id)) {
  if (is.na(out_players$pos[i])) {
    next()
  } else {
    out[[i]] <- player_info(out_players$id[i])
    out[[i]] <- map(out[[i]], ~ifelse(is.null(.), NA, .))
  }
  setTxtProgressBar(pb, i)
}

out_players <- map_df(out, tibble::as_tibble)
out_players <- mutate(out_players, across(dob, as.Date))
out_players <- select(out_players, -pos)
def_players <- filter(nfl_players, pos == "DS")
nfl_players <- select(nfl_players, id, pro, pos)
zzz <- inner_join(nfl_players, out_players)
zzz <- relocate(zzz, pro, pos, .after = last)

nfl_players <- bind_rows(zzz, def_players)
nfl_players <- select(nfl_players, -birth_place, -draft)
usethis::use_data(nfl_players, overwrite = TRUE)
