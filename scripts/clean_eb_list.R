### Create DF with links to all EB surveys + date for fieldwork

url <- "http://www.etracker.de/lnkcnt.php?et=qPKGYV&url=http://www.gesis.org/fileadmin/upload/dienstleistung/daten/umfragedaten/eurobarometer/eb_standard/eb_countries-over-time.xlsx&lnkname=fileadmin/upload/dienstleistung/daten/umfragedaten/eurobarometer/eb_standard/eb_countries-over-time.xlsx"

dest <- "data_raw/eb_countries-over-time.xlsx"

if(!dir.exists("data_raw")) dir.create("data_raw")
if(!dir.exists("data_clean")) dir.create("data_clean")
if(!file.exists(dest)) download.file(url, dest, mode = "wb")

eb_list <- readxl::read_excel(dest, col_names = FALSE)

eb_list <- eb_list[c(1, 2, 3, 6) ,]

eb_list %<>% as.matrix() %>% t() %>% as.data.frame() %>% tbl_df()
names(eb_list) <- eb_list[1, ] %>% unlist() %>% make.names()
eb_list %<>% .[-c(1:4), ]

eb_list$Standard.module %<>% str_detect(., "x")
eb_list$Standard.module[is.na(eb_list$Standard.module)] <- FALSE

eb_list$DOI %<>% paste0("http://dx.doi.org/", .)

save(eb_list, file = "data_clean/eb_list.RData")
