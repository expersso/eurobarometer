# Rename downloaded files to their EB wave names
old_name <-
  list.files("data_raw/EB", "*.dta", full.names = TRUE) %>%
  file.info() %>%
  .[order(.$mtime)] %>%
  row.names()

new_name <- paste0("data_raw/EB/", eb_list$Eurobarometer.Survey[download_index], ".dta")

if(length(old_name) == length(new_name)) {
  mapply(file.rename, old_name, new_name)
} else {
  warning("It appears you already have .dta files in that folder.
          Please empty folder first.")
}

