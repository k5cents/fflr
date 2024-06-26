% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{nfl_schedule}
\alias{nfl_schedule}
\title{2023 NFL Schedule}
\format{
A data frame with 544 rows and 6 variables:
\describe{
\item{seasonId}{Season year}
\item{scoringPeriodId}{Scoring period}
\item{matchupId}{Unique ID for professional matchup}
\item{proTeam}{Professional team abbreviation}
\item{opponent}{Professional team opponent}
\item{isHome}{Whether this is the home team}
\item{date}{Matchup start date and time}
...
}
}
\source{
\url{https://lm-api-reads.fantasy.espn.com/apis/v3/games/ffl/seasons/2023?view=proTeamSchedules_wl}
}
\usage{
nfl_schedule
}
\description{
The 2023 NFL season schedule by team, as of September 10th.
}
\keyword{datasets}
