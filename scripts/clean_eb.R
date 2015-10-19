# Test: work with trends data ---------------------------------------------


if(!file.exists("data_clean/df_trends.RData")) {
  df_trends <- get_trend_categories()
  save(df_trends, file = "data_clean/df_trends.RData")
}

load("data_clean/df_trends.RData")

trend_table <- df_trends %>% get_trend_tables("Trust in European institutions")

files <- get_matching_files("data_raw/eb", trend_table[[2]]$`ZA Study Number`)

dfs <- lapply(files, read_eb)
vars <- trend_table[[2]]$`Variable Name`

vars <- lapply(dfs, function(x) find_var(x, "european central bank - trust"))

index <- sapply(vars, function(x) length(nchar(x)) != 0)

vars <- vars[index] %>% unlist()
dfs <- dfs[index]

head_eb(dfs, vars, FALSE)
