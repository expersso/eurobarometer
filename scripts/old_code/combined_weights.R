source("scripts/gesis.R")
source("scripts/scrape_trends.R")
source("scripts/clean_eurobarometer.R")

df_trends <- get_trend_categories()
trends <- df_trends %>% get_trend_tables("Trust in European institutions")

df <- read_eb("data_raw/eb/ZA5928_v2-0-0.dta")
find_var(df, "trust")

# Use united DE and GB weights
df$w1 <- ifelse(df$cntry_de == 1, df$w3,
         ifelse(df$cntry_gb == 1, df$w4,
                df$w1))

# Replace DE-W/DE-E and GB splits by united DE and GB
df$isocntry <- ifelse(df$cntry_de == 1, "DE",
               ifelse(df$cntry_gb == 1, "GB",
                      df$isocntry))

df$qa1 <- as_factor(df$qa1)

# Creates data frame with aggregation group, question, share of responses
get_response <- function(data, group, question, weights, aggregation = NULL) {

  # If aggregating to e.g. "EU28"
  if(!is.null(aggregation)) {
    data[[group]] <- aggregation
  }

  df <- data %>%
    group_by(group = .[[group]]) %>%
    do(value = sapply(levels(.[[question]]), function(x) {
      sum((.[[question]] == x) * .[[weights]]) / sum(.[[weights]])})) %>%
    unnest(value)

  df$response <- levels(data[[question]])
  df
}

df_all <- rbind(get_response(df, "isocntry", "qa2a", "w1"),
                get_response(df, "isocntry", "qa2a", "w23", "EU28"),
                get_response(df, "isocntry", "qa2a", "w98", "EA"))

df_all$group[df_all$group == "EA"] <- "U2"
df_all %<>% left_join(df_codes, by = c("group" = "iso2c"))
df_all$country[df_all$group == "U2"] <- "Euro area"
df_all$country[is.na(df_all$country)] <- "EU28"
# df_all$response %<>% factor(levels = c("Easier", "More difficult",
#                                        "About the same", "DK"))

cntryorder <- df_all %>%
  filter(response == "Easier") %>%
  arrange(value) %>%
  select(country) %>%
  unlist()

ggplot(df_all, aes(x = factor(country, cntryorder), y = value, fill = response)) +
  geom_bar(stat = "identity", position = "stack") +
  coord_flip() +
  scale_y_continuous(labels = percent, expand = c(0, 0)) +
  labs(x = NULL, y = "% of respondents", fill = "Response")


df_qa2a <- df_all %>% select(response, group, value) %>% spread(group, value)

write.csv(df_qa2a, "data/df_qa2a.csv", row.names = FALSE)
