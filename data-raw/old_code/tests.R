# Survey package test -----------------------------------------------------

library(survey)

df <- dfs[[33]]

srs_design <- svydesign(id = ~1, strata = ~`COUNTRY CODE - ISO 3166`,
                        data = df,
                        weights = ~`WEIGHT RESULT FROM TARGET (REDRESSMENT)`)

tab <- svymean(~interaction(`COUNTRY CODE - ISO 3166`,
                            `EUROPEAN CENTRAL BANK - TRUST`),
               srs_design, na.rm=TRUE)

names(tab) <- str_replace(names(tab), "^.*?\\)", "")

countries <- levels(df$`COUNTRY CODE - ISO 3166`)
trustlevs <- c("Trust", "No trust", "DK", "Inap")

ftab <- ftable(tab, rownames = list(trustlevs, countries))

round(prop.table(ftab, 1), 2)

test <- tab %>%
  as.data.frame() %>%
  mutate(var = rownames(.)) %>%
  filter(!str_detect(var, "Inap")) %>%
  separate(var, c("cntry", "response"), "\\.") %>%
  gather(key = stat, value = value, -cntry, -response) %>%
  spread(key = response, value = value)

test[3:5] <- t(apply(test[3:5], 1, function(x) x / sum(x)))

# dplyr test --------------------------------------------------------------

test <- df %>%
  group_by(`COUNTRY CODE - ISO 3166`) %>%
  summarise(ss = sum(
    (`EUROPEAN CENTRAL BANK - TRUST` == "Tend to trust") *
      `WEIGHT RESULT FROM TARGET (REDRESSMENT)`, na.rm=T) /
              sum(`WEIGHT RESULT FROM TARGET (REDRESSMENT)`))

calc_share(df, "COUNTRY CODE - ISO 3166", "EUROPEAN CENTRAL BANK - TRUST",
           "WEIGHT RESULT FROM TARGET (REDRESSMENT)")
