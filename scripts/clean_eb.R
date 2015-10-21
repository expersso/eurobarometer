# Get DFs corresponding to specific trend ---------------------------------

source("scripts/trends.R")
source("scripts/eurobarometer_utils.R")

df_trends <- get_trend_categories()

trend_table <- df_trends %>% get_trend_tables("Trust in European institutions")

files <- get_matching_files("data_clean/eb/", trend_table[[2]]$`ZA Study Number`)

dfs <- load_eb(files)

# Remove DFs without questions on ECB -------------------------------------

var_of_interest <- lapply(dfs, find_var, "european central bank - trust")
index <- sapply(var_of_interest, function(x) length(nchar(x)) != 0)

var_of_interest <- var_of_interest[index] %>% unlist()
dfs <- dfs[index]

# Find weights and grouping variable --------------------------------------

main_wt <- sapply(dfs, find_var, paste0("(POST-STRATIFICATION WEIGHT)|",
                                        "(WEIGHT RESULT FROM T[AR]{2}GET",
                                        "($|( \\(REDRESSMENT\\))))")
)

countries <- sapply(dfs, find_var, "ISO 3166")

# Calculate shares, add dates ---------------------------------------------

df_derived <- Map(calc_share,
                  data = dfs,
                  group = countries,
                  question = var_of_interest,
                  weights = main_wt)

df_derived <- set_dates(df_derived, dfs, "coll_date_mid")

df_all <- rbind_all(df_derived)


# Plots -------------------------------------------------------------------

all_na_cntry <- df_all %>%
  group_by(group, coll_date_mid) %>%
  summarize(all_zero = sum(value) == 0) %>%
  filter(all_zero) %>%
  .$group

df_all$response[!(df_all$response %in%
                    c("Tend to trust", "Tend not to trust"))] <- "DK"

testdf <- df_all %>%
  filter(!group %in% all_na_cntry, !is.nan(value)) %>%
  group_by(group, coll_date_mid, response) %>%
  summarize(value = sum(value, na.rm = TRUE)) %>%
  spread(key = response, value = value) %>%
  mutate(dontknow = 1 - rowSums(.[3:5])) %>%
  select(-DK) %>%
  gather(key = response, value = value, -group, -coll_date_mid)

testdf %>%
  ggplot(aes(x = coll_date_mid, y = value, color = response)) +
  geom_line() +
  facet_wrap(~group) +
  scale_y_continuous(labels = percent, expand = c(0, 0)) +
  labs(x = NULL, y = "% of respondents")


# Test against Commission data --------------------------------------------

dfat <- testdf %>%
  filter(group == "AT") %>%
  mutate(value = round(100 * value, 0)) %>%
  spread(key = response, value = value) %>%
  select(coll_date_mid, `Tend to trust`, `Tend not to trust`, dontknow)

write.csv(dfat, file = "data_raw/dfat.csv", row.names = FALSE)
