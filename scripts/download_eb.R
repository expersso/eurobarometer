### Download all eb files (in .dta format)

# Check if there are missing EB datasets ----------------------------------
existing_files <- list.files("data_raw/eb/") %>% str_sub(3, 6)
remaining_files <- setdiff(eb_info$doi, existing_files)
remaining_files <- remaining_files[remaining_files != "4565"] # Weird zip file

# Download remaining datasets ---------------------------------------------
if(length(remaining_files) > 0 ) {

  source("data_raw/gesis_login_detail.R") # gesis login details

  gesis_remDr <- setup_gesis(download_dir = "data_raw/eb/")
  login_gesis(gesis_remDr, getOption("gesis_user"), getOption("gesis_pass"))

  lapply(remaining_files, function(x) {

    message("Downloading DOI: ", x, " - ", format(Sys.time()), "\n", sep = "")
    download_dataset(gesis_remDr, x, "dta")

  })

  gesis_remDr$close()
  gesis_remDr$closeServer()

  # Deal with single file stored as ".dta.zip"
  if(!file.exists("data_raw/eb/ZA4565_v4-0-1.dta")) {

    gesis_remDr <- setup_gesis(download_dir = "data_raw/eb/", "application/zip")
    login_gesis(gesis_remDr, getOption("gesis_user"), getOption("gesis_pass"))
    try(download_dataset(gesis_remDr, "4565", "dta"), silent = TRUE)
    gesis_remDr$close()
    gesis_remDr$closeServer()

    unzip("data_raw/eb/ZA4565_v4-0-1.dta.zip", exdir = "data_raw/eb")
    file.remove("data_raw/eb/ZA4565_v4-0-1.dta.zip")
  }
}
