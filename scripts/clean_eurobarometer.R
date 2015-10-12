library(haven)

df <- read_dta("data_raw/EB/ZA3296_v1-0-1.dta")
names(df) <- sapply(df, function(x) attr(x, "label"))

# Create factors using labels as levels, but only for suitable variables
index_relabel <- sapply(df, function(x) {
  class(x) %nin% c("numeric", "integer") &
  "<COUNTRY SPECIFIC>" %nin% names(attr(x, "labels"))
})

df[, index_relabel] <- df[, index_relabel] %>% mutate_each(funs(as_factor))
