#' Set the ESPN league ID option
#'
#' Once the league ID option is set, the `lid` argument in most functions can be
#' ignored and will be automatically set. This function uses [options()] to
#' define the "lid" option. To persist this option, set `edit` to `TRUE` and
#' open the `.Rprofile` package, where [options()] can be added to define "lid".
#'
#' @param lid ESPN league ID.
#' @param edit Should the `.Rprofile` be opened to edit? Ignored if the option
#'   is already set. Call [usethis::edit_r_profile()] if installed.
#' @param ... Arguments passed to [usethis::edit_r_profile].
#' @return The league ID, invisibly.
#' @examples
#' set_lid(252353)
#' @importFrom tibble as_tibble
#' @export
set_lid <- function(lid = NULL, edit = FALSE, ...) {
  if (is.null(getOption("lid"))) {
    options("lid" = lid)
    message("new league ID set")
    if (isTRUE(edit)) {
      if (!requireNamespace("usethis", quietly = TRUE)) {
        stop("Package \"usethis\" helps edit .Rprofile", call. = FALSE)
      } else {
        usethis::edit_r_profile(...)
        usethis::ui_code_block(sprintf("options(lid = %s)", lid))
      }
    }
  } else {
    message("league ID already set")
  }
  invisible(getOption("lid"))
}
