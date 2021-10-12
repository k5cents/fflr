## code to prepare `position_ids` dataset goes here

# Quarterback                 QB      0     1
# Team Quarterback            TQB     1
# Running Back                RB      2     2
# Running Back/Wide Receiver  RB/WR   3
# Wide Receiver               WR      4     3
# Wide Receiver/Tight End     WR/TE   5
# Tight End                   TE      6     4
# Flex                        FLEX    23
# Offensive Player Utility    OP      7
# Defensive Tackle            DT      8     9
# Defensive End               DE      9     10
# Linebacker                  LB      10    11
# Defensive Line              DL      11
# Cornerback                  CB      12    12
# Safety                      S       13    13
# Defensive Back              DB      14
# Defensive Player Utility    DP      15
# Team Defense/Special Teams  D/ST    16    16
# Place Kicker                K       17    5
# Punter                      P       18    7
# Head Coach                  HC      19    14
# Bench                       BE      20
# Injured Reserve             IR      21

pos_ids <- tibble::tribble(
  ~name, ~abbrev, ~slot, ~position,
  "Quarterback",                 "QB",      0,     1,
  "Team Quarterback",            "TQB",     1,     NA,
  "Running Back",                "RB",      2,     2,
  "Running Back/Wide Receiver",  "RB/WR",   3,     NA,
  "Wide Receiver",               "WR",      4,     3,
  "Wide Receiver/Tight End",     "WR/TE",   5,     NA,
  "Tight End",                   "TE",      6,     4,
  "Flex",                        "FLEX",    23,    NA,
  "Offensive Player Utility",    "OP",      7,    NA,
  "Defensive Tackle",            "DT",      8,     9,
  "Defensive End",               "DE",      9,     10,
  "Linebacker",                  "LB",      10,    11,
  "Defensive Line",              "DL",      11,    NA,
  "Cornerback",                  "CB",      12,    12,
  "Safety",                      "S",       13,    13,
  "Defensive Back",              "DB",      14,    NA,
  "Defensive Player Utility",    "DP",      15,    NA,
  "Team Defense/Special Teams",  "D/ST",    16,    16,
  "Place Kicker",                "K",       17,    5,
  "Punter",                      "P",       18,    7,
  "Head Coach",                  "HC",      19,    14,
  "Bench",                       "BE",      20,    NA ,
  "Injured Reserve",             "IR",      21,    NA
)

pos_ids$slot <- as.integer(pos_ids$slot)
pos_ids$position <- as.integer(pos_ids$position)

usethis::use_data(pos_ids, internal = TRUE, overwrite = TRUE)
