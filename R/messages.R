#' Fantasy league teams
#'
#' The emails, chats, notes, and messages sent by league members.
#'
#' @inheritParams ffl_api
#' @return A tibble of messages.
#' @examples
#' league_messages(leagueId = "42654852")
#' @importFrom tibble tibble
#' @family league functions
#' @export
league_messages <- function(leagueId = ffl_id(), leagueHistory = FALSE, ...) {
  dat <- ffl_api(
    leagueId = leagueId,
    leagueHistory = leagueHistory,
    view = "kona_league_messageboard",
    ...
  )
  if (leagueHistory) {
    stop("Communication not available for previous seasons")
  } else {
    parse_coms(t = dat$communication$topicsByType)
  }
}

# ESPN has renamed and added topic types over the years (CHAT became
# CHAT_ALL_MEMBERS, ACTIVITY_STATUS was added), so every type returned is
# parsed the same way rather than naming each one.
parse_coms <- function(t) {
  out <- lapply(t, parse_topic)
  out <- out[lengths(out) > 0]
  if (length(out) == 0) {
    return(empty_coms())
  }
  out <- do.call("rbind", unname(out))
  as_tibble(out[order(out$date, decreasing = TRUE), ])
}

parse_topic <- function(x) {
  if (!is.data.frame(x) || nrow(x) == 0) {
    return(NULL)
  }
  chr <- function(nm) {
    if (nm %in% names(x)) as.character(x[[nm]]) else rep(NA_character_, nrow(x))
  }
  lst <- function(nm) {
    if (nm %in% names(x)) x[[nm]] else rep(list(NULL), nrow(x))
  }
  tibble::tibble(
    id = substr(chr("id"), 1, 8),
    type = chr("type"),
    author = chr("author"),
    date = ffl_date(if ("date" %in% names(x)) x$date else rep(NA_real_, nrow(x))),
    content = chr("content"),
    messages = lst("messages"),
    viewableBy = lst("viewableBy")
  )
}

empty_coms <- function() {
  tibble::tibble(
    id = character(),
    type = character(),
    author = character(),
    date = ffl_date(numeric()),
    content = character(),
    messages = list(),
    viewableBy = list()
  )
}
