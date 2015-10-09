page <- "https://dbk.gesis.org/dbksearch/SDesc2.asp?ll=10&notabs=1&af=&nf=1&search=&search2=&db=E&no=5998" %>%
  GET()

title <- page %>%
  read_html() %>%
  html_nodes(xpath = "//li[contains(text(), 'Eurobarometer')]") %>%
  html_text() %>%
  .[-c(1:3)] %>%
  str_trim()

link <- page %>%
  read_html() %>%
  html_nodes(xpath = "//li[contains(text(), 'Eurobarometer')]//a") %>%
  html_attr("href") %>%
  paste0("https://dbk.gesis.org/dbksearch/", .)

df_eb_links <- data_frame(title, link)
df_eb_links %>% filter(!str_detect(df_eb_links$title, " \\("))
