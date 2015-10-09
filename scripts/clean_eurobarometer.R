
"There should be one single currency, the Euro, replacing the (NATIONAL CURRENCY) and all other national currencies of the Member States of the European Union (M)"

"A European economic and monetary union with one single currency, the euro"

library(haven)

df <- read_dta("test_data/ZA0986_v1-0-1.dta")
names(df) <- sapply(df, function(x) attr(x, "label"))

# Create factors using labels as levels, but only for suitable variables
index_relabel <- sapply(df, function(x) {
  class(x) %nin% c("numeric", "integer") &
  "<COUNTRY SPECIFIC>" %nin% names(attr(x, "labels"))
})

df[, index_relabel] <- df[, index_relabel] %>% mutate_each(funs(as_factor))
