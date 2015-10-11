eb_files <- list.files("data_raw/EB", "*.dta", full.names = TRUE)
eb_sqlite <- src_sqlite("data_raw/eb.sqlite", TRUE)

# Read all .dta files, insert into sqlite DB, using filename as tbl name
lapply(eb_files, function(x) {
  df <- haven::read_dta(x)
  tbl_name <- basename(x) %>% str_replace("\\.dta", "")
  copy_to(eb_sqlite, df, tbl_name, temporary = FALSE)
})
