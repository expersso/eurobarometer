### Download all EB files (in .dta format)

load("data_clean/eb_info.RData") # data frame with EB names and links
source("data_raw/gesis_login_detail.R") # gesis login details
source("scripts/gesis.R") # gesis Selenium download functions

if(!dir.exists("data_raw/EB")) dir.create("data_raw/EB")

gesis_remDr <- gesis_setup(download_dir = "data_raw/EB")
gesis_login(gesis_remDr, getOption("gesis_user"), getOption("gesis_pass"))

existing_files <- list.files("data_raw/EB") %>% str_sub(3, 6)
remaining_files <- eb_info$study_id[eb_info$study_id %nin% existing_files]
remaining_files <- remaining_files[remaining_files != "4565"] # Weird zip file

lapply(remaining_files, function(x) {

  cat("Downloading study_id: ", x, " - ", format(Sys.time()), "\n", sep = "")
  gesis_download(remDr = gesis_remDr, x)

})

gesis_remDr$close()
gesis_remDr$closeServer()

# Deal with single file stored as ".dta.zip"
if(!file.exists("data_raw/EB/ZA4565_v4-0-1.dta")) {

  gesis_remDr <- gesis_setup(download_dir = "data_raw/EB", "application/zip")
  gesis_login(gesis_remDr, getOption("gesis_user"), getOption("gesis_pass"))
  try(gesis_download(gesis_remDr, "4565"), silent = TRUE)
  gesis_remDr$close()
  gesis_remDr$closeServer()

  unzip("data_raw/EB/ZA4565_v4-0-1.dta.zip", exdir = "data_raw/EB")
  file.remove("data_raw/EB/ZA4565_v4-0-1.dta.zip")
}
