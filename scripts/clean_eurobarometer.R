library(haven)
library(labelled) # proper as_factor function

apply_names <- function(df) {

  # Store original var names as attribute
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
  keep(names(df), ~ str_detect(.x, regex(pattern, ignore_case = ignore_case)))
}

labs <- function(variable) {
  attr(variable, "labels")
}

read_eb <- function(df) {

  df <- read_dta(df)

  df %<>% apply_names()

  nas_before <- sum(is.na(df))

  df %<>% relabel_factors()

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
