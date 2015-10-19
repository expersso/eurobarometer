library(haven)
library(labelled) # proper as_factor function

apply_names <- function(df) {

  # Original variable names stored as attributes
  attr(df, "original_var_name") <- names(df)

  # Apply variable names stored as attribute "label"
  names(df) <- sapply(df, function(x) attr(x, "label"))
  names(df) <- iconv(make.unique(names(df)))

  df
}

# Create factors using labels as levels, but only for suitable variables
relabel_factors <- function(df) {

  index_relabel <- sapply(df, function(x) {
    !class(x) %in% c("numeric", "integer") &
    !"<COUNTRY SPECIFIC>" %in% names(attr(x, "labels"))
  })

  df[, index_relabel] <- df[, index_relabel] %>% mutate_each(funs(as_factor))
  df
}

find_var <- function(df, pattern, ignore_case = TRUE) {
 purrr::keep(names(df),
             ~ str_detect(.x, regex(pattern, ignore_case = ignore_case)))
}

read_eb <- function(df) {

  df <- read_dta(df)

  df <- apply_names(df)

  nas_before <- sum(is.na(df))

  df<- relabel_factors(df)

  nas_after <- sum(is.na(df))

  if(nas_after - nas_before > 0) warning("Applying labels resulted in NAs")
  df
}

get_matching_files <- function(folder, doi) {

  existing_files <- list.files(folder, full.names = TRUE)
  matching_files <- str_sub(basename(existing_files), 3, 6) %in% doi
  existing_files[matching_files]
}

head_eb <- function(df_list, var_list, original_var_name = FALSE, n = 5) {

  if(original_var_name) {
    mapply(
      function(df, var) {
        head(df[, which(attr(df, "original_var_name") == var)], n)
      },
      df = df_list,
      var = var_list
    )
    } else {
      mapply(function(df, var) head(df[var], n), df = df_list, var = var_list)
    }
  }

convert_eb_to_rdata <- function(file, save_dir) {

  filename <- tools::file_path_sans_ext(basename(file))
  doi <- str_sub(filename, 1, 6)
  df <- read_eb(file)

  filename_save <- paste0(save_dir, doi, ".Rdata")
  message("Saving: ", filename_save)
  save(df, file = filename_save)
  rm(df, doi)
}

get_eb_info <- function() {

  url <- "https://dbk.gesis.org/dbksearch/SDesc2.asp?ll=10&notabs=1&no=0986"

  eb_info <- xml2::read_html(url)
  eb_info <- xml2::xml_find_all(eb_info,
                                "//li[contains(text(), 'Eurobarometer')]")
  eb_info <- xml2::xml_text(eb_info)[-1]
  eb_info <- data.frame(title = str_trim(eb_info), stringsAsFactors = FALSE)

  eb_info$doi <- as.numeric(str_sub(eb_info$title, 1, 4))

  eb_info$title <- str_replace(eb_info$title, "[0-9]{4} ", "")
  eb_info$title <- str_replace(eb_info$title, "Eurobarometer ", "EB")

  # Drop trend files
  eb_info <- eb_info[str_detect(eb_info$title, "EB[0-9]"), ]

  # Separate title into eb_number and collection_date, clean these up
  eb_info <- separate(eb_info, title, c("eb_number", "collection_date"),
                      sep = "( \\()", fill = "right")

  eb_info$collection_date <- str_trim(
    str_replace_all(eb_info$collection_date, "[()]", ""))

  eb_info$eb_number <- str_replace_all(eb_info$eb_number, "[[:blank:]]", "")

  eb_info$doi <- str_pad(eb_info$doi, 4, pad = "0")

  eb_info[, c("doi", "eb_number", "collection_date")]
}

set_eb_attributes <- function(df_list, eb_info) {

  for(i in seq_along(names(df_list))) {
    doi <- str_extract(names(df_list)[i], "[0-9]{4}")
    attr(df_list[[i]], "doi") <- doi
    attr(df_list[[i]], "eb") <- eb_info$eb_number[match(doi, eb_info$doi)]
  }

  df_list
}
