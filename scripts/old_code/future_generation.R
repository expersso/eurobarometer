library(haven)

list_res <- lapply(list.files("data", full.names = TRUE),
                   function(dta_file) {

  message(dta_file)

  df <- read_dta(dta_file)

  # Vector of variables to extract
  vec_search_terms <-
    c("(EUROBAROMETER NUMBER)|(SURVEY (IDENTIFICATION|NUMBER))",
      "STUDY (NUMBER|ID) ?-? DISTRIBUTOR",
      "NEXT GENERATION",
      "EURO ZONE")

  # List of actual variable names
  list_search_res <- lapply(vec_search_terms, function(search_term) {
    sapply(df, function(variable) attr(variable, "label")) %>%
      .[str_detect(., search_term)]
  })

  # Extract only euro zone weights for largest grouping (i.e. changing composition)
  list_search_res[[4]] <-
    list_search_res[[4]] %>%
    .[str_detect(., "WEIGHT [A-Z]* ?EURO ZONE")] %>%
    .[!str_detect(., "HH")] %>%
    .[length(.)]

  # Create DF with only question response and euro zone weights
  df_res <- df %>%
    select(get(names(list_search_res[[3]])),
           get(names(list_search_res[[4]])))

  df_res[[1]] %<>% as_factor()

  # Calculate share of responses
  vec_res <- sapply(levels(df_res[[1]]), function(x) {
    sum((df_res[[1]] == x) * df_res[[2]], na.rm = TRUE) /
      sum(df_res[[2]], na.rm = TRUE)
  })

  # Get Eurobarometer number and study number
  metadata <- df %>%
    select(get(names(list_search_res[[1]])),
           get(names(list_search_res[[2]]))) %>%
    .[1,] %>%
    unlist()

  names(metadata) <- c("Eurobarometer_number", "Study_number")

  c(metadata, vec_res)
})

list_df_res <- lapply(list_res, function(x) {
  names(x)[str_detect(names(x), "[Nn]either")] <- "Neither"
  names(x)[str_detect(names(x), "About the same")] <- "Neither"
    x %>% as.matrix() %>% t() %>% as.data.frame()
})

# Filter vector excluding studies asking question about financial future,
# not generally about the future
vec_filter <- sapply(list_df_res, function(x) {
  !str_detect(names(x), "More secure") %>% sum()
})

df_results <- do.call(rbind.fill, list_df_res[vec_filter]) %>%
  .[,-ncol(.)] %>%
  mutate(Eurobarometer_number = Eurobarometer_number / 10,
         Year = ymd(c("2005-11-17", "2008-03-25", "2008-10-06", "2009-01-16",
                      "2009-10-23", "2011-12-03", "2012-11-17", "2014-03-15"))) %>%
  gather(key = response, value = share, -Year, -Eurobarometer_number, -Study_number)

write.csv(df_results, "data/future_generation.csv", row.names = FALSE)
