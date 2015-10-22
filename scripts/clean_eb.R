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
ages <- sapply(dfs, find_var, "(=?.*age)(=?.*6|.*six) (groups|cat)")

# Calculate shares, add dates ---------------------------------------------

df_derived <- Map(calc_share,
                  data = dfs,
                  group = countries,
                  question = var_of_interest,
                  weights = main_wt)

df_derived <- set_metadata(df_derived, dfs, "coll_date_mid")

df_all <- rbind_all(df_derived)
