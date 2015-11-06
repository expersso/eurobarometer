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

  library(labelled) # This needs to be in there for as_factor

  index_relabel <- sapply(df, function(x) {
    !class(x) %in% c("numeric", "integer") &
    !"<COUNTRY SPECIFIC>" %in% names(attr(x, "labels"))
  })

  df[, index_relabel] <- df[, index_relabel] %>%
    mutate_each(funs(as_factor))
  df
}

read_eb <- function(file) {

  df <- haven::read_dta(file)

  df <- apply_names(df)

  nas_before <- sum(is.na(df))

  df <- relabel_factors(df)

  nas_after <- sum(is.na(df))

  if(nas_after - nas_before > 0) warning("Applying labels resulted in NAs")
  df
}

convert_eb_to_rdata <- function(file, save_dir, eb_info, ...) {

  filename <- tools::file_path_sans_ext(basename(file))
  doi <- str_sub(filename, 3, 6)
  df_name <- paste0("ZA", doi)
  df <- read_eb(file)

  # Set attributes from eb_info
  attr(df, "doi") <- doi
  attr(df, "title") <- eb_info$title[match(doi, eb_info$doi)]
  attr(df, "subtitle") <- eb_info$subtitle[match(doi, eb_info$doi)]
  attr(df, "coll_date_mid") <- eb_info$coll_date_mid[match(doi, eb_info$doi)]
  attr(df, "start_date") <- eb_info$start_date[match(doi, eb_info$doi)]
  attr(df, "end_date") <- eb_info$end_date[match(doi, eb_info$doi)]

  # Save as .RData file
  assign(df_name, df)
  if(str_sub(save_dir, -1, -1) == "/") { # Remove trailing slash
    save_dir <- str_sub(save_dir, 1, -2)
  }
  filename_save <- paste0(save_dir, "/ZA", doi, ".RData")
  message("Saving: ", filename_save)
  save(list = df_name, file = filename_save)
}

get_eb_info <- function() {

  url <- "https://dbk.gesis.org/dbksearch/SDesc2.asp?ll=10&notabs=1&no=0986"

  eb_info <- read_html(url)
  eb_info <- xml_find_all(eb_info,
                                "//a[string-length(text()) = 4]//parent::li")
  eb_info <- xml_text(eb_info)

  eb_info <- data.frame(title = str_trim(eb_info),
                        stringsAsFactors = FALSE)

  eb_info$doi <- as.numeric(str_sub(eb_info$title, 1, 4))

  eb_info$title <- str_replace(eb_info$title, "[0-9]{4} ", "")
  eb_info$title <- str_replace(eb_info$title, "Eurobarometer ", "EB")

  # Drop trend files
  keep_index <- str_detect(eb_info$title,
             "EB[0-9]|European Communities Study|Attitudes towards Europe")
  eb_info <- eb_info[keep_index, ]

  # Drop dates in parentheses
  eb_info$title <- str_trim(
    str_replace_all(eb_info$title, "\\(.*\\)", "")
    )

  eb_info$doi <- str_pad(eb_info$doi, 4, pad = "0")

  eb_info[, c("doi", "title")]
}

get_metadata <- function(doi, metadata) {

  base_url <- "https://dbk.gesis.org/dbksearch/SDesc2.asp?ll=10&notabs=1&no=%s"
  url <- sprintf(base_url, doi)
  page <- read_html(url)

  output_list <- lapply(metadata, function(meta_text) {

    base_xpath <- "//td[contains(text(), '%s')]//following-sibling::td"
    xpath <- sprintf(base_xpath, meta_text)

    output <- xml_text(xml_find_all(page, xpath))
    output <- str_trim(output[length(output)])
    output
  })

  names(output_list) <- unlist(metadata)
  as.data.frame(t(output_list), stringsAsFactors = FALSE)
}
