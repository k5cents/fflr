## code to prepare `nfl_schedule` dataset goes here
library(fflr)

nfl_schedule <- pro_schedule()
usethis::use_data(nfl_schedule, overwrite = TRUE)
