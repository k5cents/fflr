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

parse_coms <- function(t) {
  email <- tibble::tibble(
    id = substr(t$EMAIL$id, 1, 8),
    type = t$EMAIL$type,
    author = t$EMAIL$author,
    date = ffl_date(t$EMAIL$date),
    content = t$EMAIL$content,
    messages = list(NULL),
    viewableBy = t$EMAIL$viewableBy
  )
  note <- tibble::tibble(
    id = substr(t$NOTE$id, 1, 8),
    type = t$NOTE$type,
    author = t$NOTE$author,
    date = ffl_date(t$NOTE$date),
    content = t$NOTE$content,
    messages = list(NULL),
    viewableBy = list(NULL)
  )
  board1 <- tibble::tibble(
    id = substr(t$MSG_BOARD_GROUP$id, 1, 8),
    type = t$MSG_BOARD_GROUP$type,
    author = t$MSG_BOARD_GROUP$author,
    date = ffl_date(t$MSG_BOARD_GROUP$date),
    content = t$MSG_BOARD_GROUP$content,
    messages = t$MSG_BOARD_GROUP$messages,
    viewableBy = list(NULL)
  )
  board2 <- tibble::tibble(
    id = substr(t$MSG_BOARD$id, 1, 8),
    type = t$MSG_BOARD$type,
    author = t$MSG_BOARD$author,
    date = ffl_date(t$MSG_BOARD$date),
    content = t$MSG_BOARD$content,
    messages = t$MSG_BOARD_GROUP$messages,
    viewableBy = list(NULL)
  )
  chat <- tibble::tibble(
    id = substr(t$CHAT$messages[[1]]$id, 1, 8),
    type = t$CHAT$type,
    author = t$CHAT$message[[1]]$author,
    date = ffl_date(t$CHAT$messages[[1]]$date),
    content = t$CHAT$messages[[1]]$content,
    messages = list(NULL),
    viewableBy = list(NULL)
  )
  as_tibble(rbind(email, chat, board1, board2, note))
}
