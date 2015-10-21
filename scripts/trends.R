# Functions for working with EB trends ------------------------------------

get_trend_categories <- function() {

  url <- "http://www.gesis.org/eurobarometer-data-service/topics-trends-question-retrieval/eb-trends-trend-files/list-of-trends/"

  page <- xml2::read_html(url)

  category_lengths <- page %>%
    xml2::xml_find_all("//div[@id='c5197']//ul") %>%
    vapply(xml2::xml_length, integer(1))

  main_category <- page %>%
    xml2::xml_find_all("//div[@id='c5197']/h4") %>%
    xml2::xml_text() %>%
    rep(times = category_lengths) %>%
    stringr::str_trim()

  sub_category <- page %>%
    xml2::xml_find_all("//div[@id='c5197']/ul//li") %>%
    xml2::xml_text() %>%
    stringr::str_trim() %>%
    iconv("utf-8", "latin1")

  url <- page %>%
    xml2::xml_find_all("//div[@id='c5197']/ul//li") %>%
    lapply(function(x) xml2::xml_attr(xml2::xml_children(x), "href")) %>%
    vapply(function(x) x[1], character(1))

  url[!is.na(url)] <- paste0("http://www.gesis.org/", url[!is.na(url)])

  df_trends <- data_frame(main_category, sub_category, url)
  df_trends
}

browse_trends <- function(df, trend, ...) {
  url <- df$url[match(trend, df$sub_category)]
  utils::browseURL(url, ...)
}

get_trend_tables <- function(df, trend) {

  url <- df$url[match(trend, df$sub_category)]

  if(is.na(url)) stop("There is no page for this trend variable.")

  page <- xml2::read_html(url)

  list_tables <- rvest::html_table(page, header = TRUE, fill = TRUE)

  # Clean variables names
  list_tables <- lapply(list_tables, function(x) {
    names(x) <- stringr::str_trim(iconv(names(x), "utf-8", "latin1"))
    names(x) <- stringr::str_replace_all(names(x), " \\([0-9]*\\)", "")
    x
    })

  # Drop degenerate tables with only one entry (due to website bugs)
  keep_index <- vapply(list_tables, function(x) ncol(x) != 1, logical(1))
  list_tables <- list_tables[keep_index]

  # Clean variables, drop all NA rows and columns
  list_tables <- lapply(list_tables, function(df) {
    df[] <- apply(df, 2, function(x) iconv(x, "utf-8", "latin1"))
    df[] <- apply(df, 2, function(x) {
      ifelse(stringr::str_detect(x, "(^[[:blank:]]*$)"), NA, x)
    })
    df[] <- apply(df, 2, function(x) {
      ifelse(nchar(x) == 0, NA, x)
    })
    df <- df[rowSums(is.na(df)) < ncol(df), colSums(is.na(df)) < nrow(df)]
    df <- df[!stringr::str_detect(df[,1], "[[:alpha:]]"), ]
  })

  # Add leading zeroes to ZA Study number and replace V with v in variable name
  for(i in seq_along(list_tables)) {
    list_tables[[i]][, 1] <- formatC(as.numeric(list_tables[[i]][, 1]),
                                     width = 4, flag = "0")
    list_tables[[i]][, 6] <- stringr::str_replace(list_tables[[i]][, 6], "V", "v")
  }

  # Set wording of respective question as attribute "question"
  # Will give NAs if only response options have changed
  table_titles <- page %>%
    xml2::xml_find_all("//table//preceding-sibling::h4[1]") %>%
    xml2::xml_text()

  table_titles[1] <- page %>%
    xml2::xml_find_all("//h4[2]/text()") %>%
    xml2::xml_text()

  table_titles <- stringr::str_trim(iconv(table_titles, "utf-8", "latin1"))

  for(df in seq_along(list_tables)) {
    attr(list_tables[[df]], "question") <- table_titles[df]
  }

  list_tables
}
