#' Backend: SAP HANA
#'
#' @description
#' See `vignette("translation-function")` and `vignette("translation-verb")` for
#' details of overall translation technology. Key differences for this backend
#' are:
#'
#' * Temporary tables get `#` prefix and use `LOCAL TEMPORARY COLUMN`.
#' * No table analysis performed in [copy_to()].
#' * `paste()` uses `||`
#' * Note that you can't create new boolean columns from logical expressions;
#'   you need to wrap with explicit `ifelse`: `ifelse(x > y, TRUE, FALSE)`.
#'
#' Use `simulate_hana()` with `lazy_frame()` to see simulated SQL without
#' converting to live access database.
#'
#' @name backend-hana
#' @aliases NULL
#' @examples
#' library(dplyr, warn.conflicts = FALSE)
#'
#' lf <- lazy_frame(a = TRUE, b = 1, c = 2, d = "z", con = simulate_hana())
#' lf %>% transmute(x = paste0(d, " times"))
NULL

#' @export
#' @rdname backend-hana
simulate_hana <- function() simulate_dbi("HDB")

#' @export
dbplyr_edition.HDB <- function(con) {
  2L
}

#' @export
sql_translation.HDB <- function(con) {
  sql_variant(
    sql_translator(.parent = base_scalar,
      as.character = sql_cast("VARCHAR"),
      as.numeric = sql_cast("DOUBLE"),
      as.double = sql_cast("DOUBLE"),

      # string functions ------------------------------------------------
      paste = sql_paste_infix(" ", "||", function(x) sql_expr(cast(!!x %as% text))),
      paste0 = sql_paste_infix("", "||", function(x) sql_expr(cast(!!x %as% text))),
      str_c = sql_paste_infix("", "||", function(x) sql_expr(cast(!!x %as% text))),

      # https://help.sap.com/viewer/7c78579ce9b14a669c1f3295b0d8ca16/Cloud/en-US/20e8341275191014a4cfdcd3c830fc98.html
      substr = sql_substr("SUBSTRING"),
      substring = sql_substr("SUBSTRING"),
      str_sub = sql_str_sub("SUBSTRING"),
    ),
    base_agg,
    base_win
  )
}

# nocov start
#' @export
db_table_temporary.HDB <- function(con, table, temporary, ...) {
  if (temporary && substr(table, 1, 1) != "#") {
    table <- hash_temp(table)
  }

  list(
    table = table,
    temporary = FALSE
  )
}
# nocov end

#' @export
`sql_table_analyze.HDB` <- function(con, table, ...) {
  # CREATE STATISTICS doesn't work for temporary tables, so
  # don't do anything at all
}

#' @export
sql_values_subquery.HDB <- function(con, df, types, lvl = 0, ...) {
  sql_values_subquery_union(con, df, types = types, lvl = lvl, from = "DUMMY")
}
