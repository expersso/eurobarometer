# Get DFs corresponding to specific trend ---------------------------------
source("scripts/trends.R")
source("scripts/eurobarometer_utils.R")

df_trends <- get_trend_categories()

trend_table <- df_trends %>%
  get_trend_tables("Trust in European institutions")

files <- get_matching_files("data_clean/eb/", trend_table[[2]]$`ZA Study Number`)

dfs <- load_eb_files(files)


# Remove DFs without questions on ECB -------------------------------------
vars <- lapply(dfs, find_var, "european central bank - trust")
index <- sapply(vars, function(x) length(nchar(x)) != 0)

vars <- vars[index] %>% unlist()
dfs <- dfs[index]
o
test <- Map(`[[`, dfs, vars)

res <- sapply(test, function(x) sum(x == "Tend to trust", na.rm = TRUE) / length(x))

dates <- sapply(dfs, attr, which = "coll_date_mid") %>% as.Date(origin = origin)
