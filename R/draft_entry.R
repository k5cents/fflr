#' Format a single draft pick
#'
#' Take a team's roster entry list and return a single row tibble. This function
#' is used in [form_roster()] to combine the entries from an entire team into a
#' single tibble.
#'
#' @param entry The `entry` element of `roster` list from a `team` list.
#' @return A single row tibble roster entry.
#' @examples
#' data <- ff_draft(lid = 252353)
#' draft_entry(pick = data$draftDetail$picks[[2]])
#' @importFrom purrr map
#' @importFrom tibble tibble
#' @export
draft_entry <- function(pick) {
  tibble::tibble(
    overall = pick$overallPickNumber,
    round = pick$roundId,
    nom = pick$nominatingTeamId,
    id = pick$playerId,
    team = pick$teamId,
    bid = pick$bidAmount
  )
}
