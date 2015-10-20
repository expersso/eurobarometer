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

load_eb_files <- function(eb_files) {
  vapply(eb_files, function(x) mget(load(x)), FUN.VALUE = vector("list", 1L))
}
