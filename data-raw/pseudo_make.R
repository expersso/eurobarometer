library(dplyr)
library(stringr)
library(xml2)
library(gesis)

# Get utility functions
source("data-raw/clean_eurobarometer.R")

if(!dir.exists("data-raw")) dir.create("data-raw")
if(!dir.exists("data-raw/eb")) dir.create("data-raw/eb")

# Scrape eb info table (title, doi, coll_date, subtitle) ------------------
if(!file.exists("data/eb_info.RData")) {
  eb_info <- get_eb_info()

  # Add metadata
  metadata_list <- list("Date of Collection", "Other Title")
  metadata <- lapply(eb_info$doi, get_metadata, metadata = metadata_list)
  metadata <- do.call(rbind, metadata)

  eb_info <- cbind(eb_info, metadata)
  names(eb_info)[3:4] <- c("coll_date", "subtitle")
  eb_info$subtitle <- str_trim(str_replace_all(eb_info$subtitle, "\\(.*\\)", ""))

  # Split date into start/end data, add first day of month if missing
  # convert to Date, calculate date mid point
  eb_info <- eb_info %>%
    separate(coll_date, c("start_date", "end_date"), sep = " - ") %>%
    mutate_each(funs(ifelse(str_detect(., "^[0-9]{2}\\.[0-9]{4}$"),
                            paste0("01.", .), .)), start_date, end_date) %>%
    mutate_each(funs(as.Date(., "%d.%m.%Y")), start_date, end_date) %>%
    rowwise() %>%
    mutate(date = lubridate::floor_date(mean(c(start_date, end_date)), "day")) %>%
    select(doi, title, subtitle, date, start_date, end_date)

  save(eb_info, file = "data/eb_info.RData")
}

load("data/eb_info.RData")

# Loop over DOIs in eb_info table, download all EBs to data-raw/eb --------
source("data-raw/download_eb.R")

# Clean and convert all .dta files to .RData files in data/eb -------------

dta_files <- list.files("data-raw/eb", "*.dta", full.names = TRUE)
for(file in dta_files) convert_eb_to_rdata(file, "data/", eb_info)
