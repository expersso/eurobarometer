load("data_clean/eb_list.RData") # data frame with EB names and links
source("data_raw/gesis_login_detail.R") # gesis login details
source("scripts/gesis.R") # gesis Selenium download functions

if(!dir.exists("data_raw/EB")) dir.create("data_raw/EB")

gesis_remDr <- gesis_setup(download_dir = "data_raw/EB")
gesis_login(gesis_remDr, getOption("gesis_user"), getOption("gesis_pass"))

download_index <- 188:190
lapply(eb_list$DOI[download_index], gesis_download, remDr = gesis_remDr)

# Rename downloaded files to their EB wave names
old_name <-
  list.files("data_raw/EB", "*.dta", full.names = TRUE) %>%
  file.info() %>%
  .[order(.$mtime)] %>%
  row.names()

new_name <- paste0("data_raw/EB", eb_list$Eurobarometer.Survey[download_index], ".dta")
mapply(file.rename, old_name, new_name)
