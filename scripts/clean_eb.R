# Test: work with trends data ---------------------------------------------

df_trends <- get_trend_categories()

trend_table <- df_trends %>% get_trend_tables("Trust in European institutions")

files <- get_matching_files("data_clean/eb/", trend_table[[2]]$`ZA Study Number`)

dfs <- read_eb_files(files)

vars <- trend_table[[2]]$`Variable Name`

vars <- lapply(dfs, function(x) find_var(x, "european central bank - trust"))

index <- sapply(vars, function(x) length(nchar(x)) != 0)

vars <- vars[index] %>% unlist()
dfs <- dfs[index]

head_eb(dfs, vars, FALSE)
