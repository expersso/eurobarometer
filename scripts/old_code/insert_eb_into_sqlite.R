eb_files <- list.files("data", "*.dta", full.names = TRUE)
eb_sqlite <- src_sqlite("data_raw/eb.sqlite", TRUE)

library(haven)

# Read all .dta files, insert into sqlite DB, using DOI as tbl name
lapply(eb_files, function(x) {
  df <- read_dta(x)
  tbl_name <- basename(x) %>% str_sub(1, 6)
  copy_to(dest = eb_sqlite, df = df, name = tbl_name, temporary = FALSE)
})

rm(df, tbl_name)
