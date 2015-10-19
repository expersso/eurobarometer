library(gesis)
source("scripts/clean_eurobarometer.R")

if(!dir.exists("data_raw"))   dir.create("data_raw")
if(!dir.exists("data_clean")) dir.create("data_clean")

# Scrape eb info table (eb number, doi, date) -----------------------------
eb_info <- get_eb_info()

# Loop over DOIs in eb_info table, download all EBs to data_raw/eb --------
if(!dir.exists("data_raw/eb")) {
  dir.create("data_raw/eb")
  source("scripts/download_eb.R")
}

# Clean and convert all .dta files to .RData files in data_clean/eb -------
if(!dir.exists("data_clean/eb")) {
  dir.create("data_clean/eb")
  dta_files <- list.files("data_raw/eb", "*.dta", full.names = TRUE)
  for(file in dta_files) convert_eb_to_rdata(file, "data_clean/eb/", eb_info)
}
