## code to prepare `stat_ids` dataset goes here
library(readr)

stat_ids <- read_csv(
  file = "data-raw/stat-ids.csv",
  col_types = cols(
    defaultPoints = col_double(),
    statId = col_integer()
  )
)

stat_ids <- stat_ids %>%
  select(-category, -defaultPoints) %>%
  distinct()

usethis::use_data(stat_ids, pos_ids, internal = TRUE, overwrite = TRUE)
