#' Fantasy league teams
#'
#' The emails, chats, notes, and messages sent by league members.
#'
#' @inheritParams draft_picks
#' @return A tibble of messages.
#' @examples
#' league_messages(lid = 252353)
#' @importFrom tibble as_tibble tibble
#' @export
league_messages <- function(lid = getOption("lid"), old = FALSE, ...) {
  d <- ffl_api(lid, view = "kona_league_messageboard", ...)
  t <- d$communication$topicsByType
  if (old) {
    stop("communication empty for past seaons")
  } else {
    parse_coms(t)
  }
}

parse_coms <- function(t) {
  email <- tibble::tibble(
    id = substr(t$EMAIL$id, 1, 8),
    type = t$EMAIL$type,
    author = t$EMAIL$author,
    date = ffl_date(t$EMAIL$date),
    content = t$EMAIL$content,
    view_by = t$EMAIL$viewableBy
  )
  note <- tibble::tibble(
    id = substr(t$NOTt$id, 1, 8),
    type = t$NOTt$type,
    author = t$NOTt$author,
    date = ffl_date(t$NOTt$date),
    content = t$NOTt$content,
    view_by = list(NULL)
  )
  board <- tibble::tibble(
    id = substr(t$MSG_BOARD_GROUP$id, 1, 8),
    type = t$MSG_BOARD_GROUP$type,
    author = t$MSG_BOARD_GROUP$author,
    date = ffl_date(t$MSG_BOARD_GROUP$date),
    content = t$MSG_BOARD_GROUP$content,
    view_by = list(NULL)
  )
  board$type <- "BOARD"
  chat <- tibble::tibble(
    id = substr(t$CHAT$messages[[1]]$id, 1, 8),
    type = t$CHAT$type,
    author = t$CHAT$message[[1]]$author,
    date = ffl_date(t$CHAT$messages[[1]]$date),
    content = t$CHAT$messages[[1]]$content,
    view_by = list(NULL)
  )
  tibble::as_tibble(rbind(email, chat, board, note))
}
