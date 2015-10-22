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
