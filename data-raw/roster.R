library(tidyverse)
library(fflr)

data <- fantasy_roster(gaa, scoringPeriodId = 3)
roster <- form_roster(data$teams[[5]])

usethis::use_data(roster, overwrite = TRUE)
