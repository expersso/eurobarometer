eb_info <- "https://dbk.gesis.org/dbksearch/SDesc2.asp?ll=10&notabs=1&no=0986" %>%
  GET() %>%
  read_html() %>%
  html_nodes(xpath = "//li[contains(text(), 'Eurobarometer')]") %>%
  html_text() %>%
  .[-c(1:3)] %>%
  str_trim() %>%
  data_frame()

names(eb_info) <- "title"

eb_info$doi <- eb_info$title %>% str_sub(1, 4) %>% as.numeric()

eb_info$title %<>% str_replace("[0-9]{4} ", "") %>%
  str_replace("Eurobarometer ", "EB")

# Drop trend files
eb_info %<>% filter(str_detect(title, "EB[0-9]"))

# Separate title into eb_number and collection_date, clean these up
eb_info %<>% separate(title, c("eb_number", "collection_date"),
                         sep = "( \\()", fill = "right") %>%
  mutate(collection_date = str_replace_all(collection_date, "[()]", "") %>% str_trim(),
         eb_number = str_replace_all(eb_number, "[[:blank:]]", "")) %>%
  select(doi, eb_number, collection_date)

eb_info$doi %<>% str_pad(4, pad = "0")

save(eb_info, file = "data_clean/eb_info.RData")
