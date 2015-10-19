for(var in seq_along(df)) {

  attr(df[[var]], "labels") <-
    attr(df[[var]], "labels")[str_sub(as.character(attr(df[[var]], "labels")),
                                      1, 4) != "2147"]
}

df %<>% relabel_factors()


test <- df$`D1 LEFT-RIGHT PLACEMENT`

missing_labels <- setdiff(na.omit(unique(test)), attr(test, "labels"))

attr(test, "labels") <- c(attr(test, "labels"), missing_labels)

names(attr(test, "labels"))[names(attr(test, "labels")) == ""] <- missing_labels

labs <- sort(attr(test, "labels"))
factor(test, levels = unname(labs), labels = names(labs)) %>% head

x <- labelled(c(1, 2, 1, 2, 10, 9), c(Unknown = 9, Refused = 10))
as_factor(test) %>% head()

test_nas <- function(df) {
  apply(df, 2, function(x) sum(is.na(x), na.rm=T))
}
