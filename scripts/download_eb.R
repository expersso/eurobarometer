load("data_clean/eb_list.RData") # data frame with EB names and links
source("data_raw/gesis_login_detail.R") # gesis login details
source("scripts/gesis.R") # gesis Selenium download functions

if(!dir.exists("data_raw/EB")) dir.create("data_raw/EB")

gesis_remDr <- gesis_setup(download_dir = "data_raw/EB")
gesis_login(gesis_remDr, getOption("gesis_user"), getOption("gesis_pass"))

download_index <- sample(nrow(eb_list), 3, replace = FALSE)
lapply(eb_list$DOI[download_index], gesis_download, remDr = gesis_remDr)
