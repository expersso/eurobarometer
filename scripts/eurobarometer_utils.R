# Find files matching a vector of DOIs
get_matching_files <- function(folder, doi) {

  existing_files <- list.files(folder, full.names = TRUE)
  matching_files <- str_sub(basename(existing_files), 3, 6) %in% doi
  existing_files[matching_files]
}

# Glimpse at first rows of set of variables in list of data frames
head_eb <- function(df_list, var_list, original_var_name = FALSE, n = 5) {

  if(original_var_name) {
    Map(
      function(df, var) {
        head(df[, which(attr(df, "original_var_name") == var)], n)
      },
      df = df_list,
      var = var_list
    )
  } else {
    Map(function(df, var) {
      tryCatch(head(df[var], n),
               error = function(e) warning("No such variable"))
      },
      df = df_list, var = var_list)
  }
}

# Load EB files converted to .RData
load_eb <- function(file) {
  vapply(file, function(x) mget(load(x)), FUN.VALUE = vector("list", 1L))
}

# Regex search variables
find_var <- function(df, pattern, ignore_case = TRUE) {
  purrr::keep(names(df),
              ~ str_detect(.x, regex(pattern, ignore_case = ignore_case)))
}

# Creates data frame with aggregation group, question, share of responses
calc_share <- function(data, group, question, weights, aggregation = NULL) {

  # If aggregating to e.g. "EU28"
  if(!is.null(aggregation)) {
    data[[group]] <- aggregation
  }

  df <- data %>%
    group_by(group = .[[group]]) %>%
    do(value = sapply(levels(.[[question]]), function(x) {
      sum((.[[question]] == x) * .[[weights]], na.rm = TRUE) / sum(.[[weights]])})) %>%
    unnest(value)

  df$response <- levels(data[[question]])
  df
}

# Set metadata for a derived dataframe
set_metadata <- function(derived_df_list, original_df_list, meta_string) {

  meta <- sapply(original_df_list, attr, which = "meta_string")

  if(any(is.Date(meta))) {
  meta <- lubridate::floor_date(as.Date(meta, origin = origin))
  }

  for(i in seq_along(meta)) {
    derived_df_list[[i]][[meta_string]] <- meta[i]
  }
  derived_df_list
}

# Find index of list of data frame by doi
doi_index <- function(df, doi) {
  vec_doi <- sapply(df, attr, which = "doi")
  which(as.character(doi) == vec_doi)
}
