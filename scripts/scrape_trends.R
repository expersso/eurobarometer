# Functions for working with EB trends ------------------------------------

get_trend_categories <- function() {

  url <- "http://www.gesis.org/eurobarometer-data-service/topics-trends-question-retrieval/eb-trends-trend-files/list-of-trends/"

  page <- read_html(url)

  category_lengths <- page %>%
    html_nodes(xpath = "//div[@id='c5197']//ul") %>%
    vapply(xml_length, integer(1))

  main_category <- page %>%
    html_nodes(xpath = "//div[@id='c5197']/h4") %>%
    html_text() %>%
    rep(times = category_lengths)

  sub_category <- page %>%
    html_nodes(xpath = "//div[@id='c5197']/ul//li") %>%
    html_text() %>%
    str_trim()

  url <- page %>%
    html_nodes(xpath = "//div[@id='c5197']/ul//li") %>%
    lapply(function(x) xml_attr(xml_children(x), "href")) %>%
    vapply(function(x) x[1], character(1))

  url[!is.na(url)] <- paste0("http://www.gesis.org/", url[!is.na(url)])

  df_trends <- data_frame(main_category, sub_category, url)
  df_trends
}

if(!file.exists("data_clean/df_trends.RData")) {
  df_trends <- get_trend_categories()
  save(df_trends, file = "data_clean/df_trends.RData")
}

browse_trends <- function(df, trend, ...) {
  url <- df$url[match(trend, df$sub_category)]
  browseURL(url, ...)
}

get_trend_tables <- function(df, trend) {

  url <- df$url[match(trend, df$sub_category)]

  if(is.na(url)) stop("There is no page for this trend variable.")

  page <- read_html(url)

  list_tables <- html_table(page, header = TRUE, fill = TRUE)

  # Clean variables names
  list_tables <- lapply(list_tables, function(x) {
    names(x) <- str_trim(iconv(names(x), "utf-8", "latin1"))
    names(x) <- str_replace_all(names(x), " \\([0-9]*\\)", "")
    x
    })

  # Clean variables, drop all NA rows
  list_tables <- lapply(list_tables, function(df) {
    df[] <- apply(df, 2, function(x) iconv(x, "utf-8", "latin1"))
    df[] <- apply(df, 2, function(x) {
      ifelse(str_detect(x, "(^[[:blank:]]*$)"), NA, x)
    })
    df[] <- apply(df, 2, function(x) {
      ifelse(nchar(x) == 0, NA, x)
    })
    df <- df[rowSums(is.na(df)) < ncol(df), ]
    df
  })

  # Set wording of respective question as attribute "question"
  # Will give NAs if only response options have changed
  table_titles <- page %>%
    html_nodes(xpath = "//table//preceding-sibling::h4[1]") %>%
    html_text()

  table_titles[1] <- page %>%
    html_nodes(xpath = "//h4[2]/text()") %>%
    html_text()

  table_titles <- str_trim(iconv(table_titles, "utf-8", "latin1"))

  for(df in seq_along(list_tables)) {
    attr(list_tables[[df]], "question") <- table_titles[df]
  }

  list_tables
}
