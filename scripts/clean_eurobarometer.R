library(haven)

apply_names <- function(df) {
    names(df) <- sapply(df, function(x) attr(x, "label"))
    df
}

# Create factors using labels as levels, but only for suitable variables
relabel_factors <- function(df) {

  index_relabel <- sapply(df, function(x) {
    class(x) %nin% c("numeric", "integer") &
    "<COUNTRY SPECIFIC>" %nin% names(attr(x, "labels"))
  })

  df[, index_relabel] <- df[, index_relabel] %>% mutate_each(funs(as_factor))
  df
}

find_var <- function(df, pattern) {
  keep(names(df), ~ str_detect(.x, pattern))
}

labs <- function(variable) {
  attr(variable, "labels")
}
