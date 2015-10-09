### Create DF with links to all EB surveys + date for fieldwork

url <- "http://www.etracker.de/lnkcnt.php?et=qPKGYV&url=http://www.gesis.org/fileadmin/upload/dienstleistung/daten/umfragedaten/eurobarometer/eb_standard/eb_countries-over-time.xlsx&lnkname=fileadmin/upload/dienstleistung/daten/umfragedaten/eurobarometer/eb_standard/eb_countries-over-time.xlsx"

dest <- "data_raw/eb_countries-over-time.xlsx"

download.file(url, dest, mode = "wb")

df <- readxl::read_excel(dest, col_names = FALSE)

df <- df[c(1, 2, 3, 6) ,]

df %<>% as.matrix() %>% t() %>% as.data.frame() %>% tbl_df()
names(df) <- df[1, ] %>% unlist() %>% make.names()
df %<>% .[-c(1:4), ]

df$Standard.module %<>% str_detect(., "x")
df$Standard.module[is.na(df$Standard.module)] <- FALSE

df$DOI %<>% paste0("http://dx.doi.org/", .)

save(df, file = "data_clean/eb_fieldwork_links.RData")
