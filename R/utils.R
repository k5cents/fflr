ffl_date <- function(date) {
  if (is.null(date)) {
    as.POSIXct(NA_real_)
  } else {
    as.POSIXct(date / 1000, origin = "1970-01-01")
  }
}

ffl_timestamp <- function(x) {
  as.POSIXlt(x, tz = "UTC", format = "%Y-%m-%dT%H:%M:%S")
}

as_tibble <- function(x) {
  if (is_installed("tibble")) {
    tibble::as_tibble(x)
  } else {
    x
  }
}

is_installed <- function(pkg) {
  isTRUE(requireNamespace(pkg, quietly = TRUE))
}

list_ifnot <- function(x) {
  if (!is.list(x)) {
    list(x)
  } else if (is.data.frame(x)) {
    list(x)
  } else {
    x
  }
}

ffl_merge <- function(x, y, ...) {
  out <- merge(x, y, sort = FALSE, ...)[, union(names(x), names(y))]
  as_tibble(out)
}

order_df <- function(dat, col, decreasing = TRUE) {
  if (is.data.frame(dat) & is.vector(col)) {
    dat[order(col, decreasing = decreasing), ]
  }
}

bind_df <- function(l, .id = NULL) {
  if (!is.null(.id) & !is.null(names(l))) {
    l <- lapply(
      X = seq_along(l),
      FUN = function(i) {
        sid <- list(names(l)[i])
        names(sid) <- .id
        cbind(sid, l[[i]])
      }
    )
  }
  out <- do.call(what = "rbind", args = l)
  as_tibble(out)
}

change_names <- function(dat, old_name, new_name) {
  names(dat)[match(old_name, names(dat))] <- new_name
  return(dat)
}

# replace_col <- function(z, old_name, ...) {
#   dots <- list(...)
#   stopifnot(length(dots) == 1, old_name %in% names(z))
#   z[[old_name]] <- dots[[1]]
#   z <- change_names(z, old_name, names(dots)[[1]])
#   return(z)
# }

col_abbrev <- function(z, col, new) {
  new_name <- gsub("Id$", "", col)
  z[[col]] <- new
  z <- change_names(z, col, new_name)
  return(z)
}

move_col <- function(df, col, n) {
  if (is.numeric(col)) {
    col <- names(df)[col]
  }
  subset(
    x = df,
    select = c(
      names(df)[seq(n - 1)],
      col,
      names(df)[!(names(df) %in% c(names(df)[seq(n - 1)], col))]
    )
  )
}

could_be_numeric <- function(x) {
  !is.na(suppressWarnings(as.numeric(x[!is.na(x)])))
}
