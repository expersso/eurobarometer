if(!dir.exists("data/rdata")) dir.create("data/rdata")
eb_clean <- src_sqlite("data/eb_clean.sqlite", TRUE)

existing_files <- list.files("data", "*.dta", full.names = TRUE)

lapply(existing_files, function(x) {

  doi <- str_sub(tools::file_path_sans_ext(basename(x)), 1, 6)
  df <-  relabel_factors(apply_names(read_dta(x)))
  copy_to(eb_clean, df, doi, temporary= FALSE)
  # save(df, file = paste0("data/rdata/", doi, ".Rdata"))

})

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
