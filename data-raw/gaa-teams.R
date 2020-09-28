gaa_teams <- structure(
  list(
    team = c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 8L, 9L, 9L, 10L, 11L),
    abbrev = structure(
      c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L, 7L, 10L, 11L, 12L),
      class = "factor",
      .Label = c(
        "AGUS", "ROWN", "PEPE", "BILL", "CART", "KIER",
        "JUST", "CHAR", "CORE", "COLN", "NICK", "KYLE"
      )
    ),
    years = list(
      2015:2020, 2015:2018, 2015:2020, 2015:2020, 2015:2020, 2015:2020,
      2015L, 2015:2018, 2019:2020, 2016L, 2017:2018, 2016:2020, 2016:2020
    )
  ),
  row.names = c(NA, -13L),
  class = c("tbl_df", "tbl", "data.frame")
)

use_data(gaa_teams, overwrite = TRUE, internal = TRUE)
