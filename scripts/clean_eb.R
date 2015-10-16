if(!dir.exists("data/rdata")) dir.create("data/rdata")
eb_clean <- src_sqlite("data/eb_clean.sqlite", TRUE)

existing_files <- list.files("data", "*.dta", full.names = TRUE)

lapply(existing_files, function(x) {

  doi <- str_sub(tools::file_path_sans_ext(basename(x)), 1, 6)
  df <-  relabel_factors(apply_names(read_dta(x)))
  copy_to(eb_clean, df, doi, temporary= FALSE)
  # save(df, file = paste0("data/rdata/", doi, ".Rdata"))

})

test <- read_eb("data_raw/EB/ZA3388_v1-1-0.dta")

url <- "http://www.gesis.org/eurobarometer-data-service/topics-trends-question-retrieval/eb-trends-trend-files/list-of-trends/peaceful/"

df_trend <- url %>%
  read_html() %>%
  html_node(xpath = "//table[@class='htmlarea-showtableborders']") %>%
  html_table(header = TRUE)


existing_files <- list.files("data_raw/EB", full.names = TRUE)

matching_files <- str_sub(basename(existing_files), 3, 6) %in%
  as.character(df_trend$`ZA Study Number`)

df_list <- lapply(existing_files[matching_files], read_eb)

lapply(df_list, find_var, "(peace - next year|next year - peace|Q114)")
