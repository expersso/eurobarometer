load("data_clean/eb_list.RData")

# put Gesis login details in this file as options "gesis_user" and "gesis_pass"
source("data_raw/gesis_login_detail.R")

url <- "https://dbk.gesis.org/dbksearch/download.asp?db=E&id=48146"

library(RSelenium)
RSelenium::checkForServer()

# set firefox properties to not open download dialog
fprof <- makeFirefoxProfile(list(
  browser.download.dir = paste0(getwd(), "/data_raw"),
  browser.download.folderList = 2L,
  browser.download.manager.showWhenStarting = FALSE,
  browser.helperApps.neverAsk.saveToDisk = "application/octet-stream"))

RSelenium::startServer()
remDr <- remoteDriver(extraCapabilities = fprof)

remDr$open()

#Login page
remDr$navigate(url)
remDr$findElement(using = "id", value = "loginContainer")$clickElement()

# Input login details
remDr$findElement(using = "name", "user")$sendKeysToElement(list(getOption("gesis_user")))
remDr$findElement(using = "name", "pass")$sendKeysToElement(list(getOption("gesis_pass")))
remDr$findElement(using = "id", "login")$clickElement()

# Input purpose and terms of use
remDr$findElement(using = "name", "projectok")$clickElement()
remDr$findElement("xpath", "//option[@value='1']")$clickElement()
remDr$findElement("xpath", "//input[@value='Download']")$clickElement()

remDr$close()
