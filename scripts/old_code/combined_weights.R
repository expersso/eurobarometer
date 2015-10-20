source("scripts/scrape_trends.R")
source("scripts/eurobarometer_utils.R")

df_trends <- get_trend_categories()
trends <- df_trends %>% get_trend_tables("Trust in European institutions")

load("data_clean/eb/ZA5928.RData")

# Use united DE and GB weights
df$main_weight <- df$`WEIGHT RESULT FROM TARGET (REDRESSMENT)`

df$main_weight[df$`NATION - UNITED GERMANY` == "Germany"] <-
  df$`WEIGHT GERMANY`[df$`NATION - UNITED GERMANY` == "Germany"]

df$main_weight[df$`NATION - UNITED KINGDOM` == "United Kingdom"] <-
  df$`WEIGHT UNITED KINGDOM`[df$`NATION - UNITED KINGDOM` == "United Kingdom"]

# Replace DE-W/DE-E and GB splits by united DE and GB
df$iso2c <- as.character(df$`COUNTRY CODE - ISO 3166`)
df$iso2c[df$`NATION - UNITED GERMANY` == "Germany"] <- "DE"
df$iso2c[df$`NATION - UNITED KINGDOM` == "United Kingdom"] <- "GB"

# Creates data frame with aggregation group, question, share of responses
get_response <- function(data, group, question, weights, aggregation = NULL) {

  # If aggregating to e.g. "EU28"
  if(!is.null(aggregation)) {
    data[[group]] <- aggregation
  }

  df <- data %>%
    group_by(group = .[[group]]) %>%
    do(value = sapply(levels(.[[question]]), function(x) {
      sum((.[[question]] == x) * .[[weights]], na.rm = TRUE) / sum(.[[weights]])})) %>%
    unnest(value)

  df$response <- levels(data[[question]])
  df
}

df_all <- rbind(
  get_response(df, "iso2c", "EUROPEAN CENTRAL BANK - TRUST", "main_weight"),
  get_response(df, "iso2c", "EUROPEAN CENTRAL BANK - TRUST", "WEIGHT EU28", "EU28"),
  get_response(df, "iso2c", "EUROPEAN CENTRAL BANK - TRUST", "WEIGHT EURO ZONE 18",
               "EA")
  )

all_na_cntry <- df_all %>%
  group_by(group) %>%
  summarize(all_zero = sum(value) == 0) %>%
  filter(all_zero) %>%
  .$group

cntryorder <- df_all %>%
  filter(!group %in% all_na_cntry) %>%
  filter(response == "Tend to trust") %>%
  arrange(value) %>%
  .$group)

df_all %>%
  filter(!group %in% all_na_cntry) %>%
  ggplot(aes(x = factor(group, cntryorder), y = value, fill = response)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_continuous(labels = percent, expand = c(0, 0)) +
  labs(x = NULL, y = "% of respondents", fill = "Response")
