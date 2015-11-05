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


df_all <- rbind(
  calc_share(df, "iso2c", "TRUST IN INSTITUTIONS: UNITED NATIONS",
             "main_weight"),
  calc_share(df, "iso2c", "TRUST IN INSTITUTIONS: UNITED NATIONS",
             "WEIGHT EU28", "EU28"),
  calc_share(df, "iso2c", "TRUST IN INSTITUTIONS: UNITED NATIONS",
             "WEIGHT EURO ZONE 18", "EA")
  )

all_na_cntry <- df_all %>%
  group_by(group, coll_date_mid) %>%
  summarize(all_zero = sum(value) == 0) %>%
  filter(all_zero) %>%
  .$group

cntryorder <- df_all %>%
  filter(!group %in% all_na_cntry) %>%
  filter(response == "Tend to trust") %>%
  arrange(value) %>%
  .$group

df_all %>%
  filter(!group %in% all_na_cntry) %>%
  ggplot(aes(x = factor(group, cntryorder), y = value, fill = response)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_continuous(labels = percent, expand = c(0, 0)) +
  labs(x = NULL, y = "% of respondents", fill = "Response")
