# Initiate Selenium server, specify Firefox profile to not ask when downloading
gesis_setup <- function(download_dir, file_mime = "application/octet-stream") {

  library(RSelenium)

  # set firefox properties to not open download dialog
  fprof <- makeFirefoxProfile(list(
    browser.download.dir = paste0(getwd(), "/", download_dir),
    browser.download.folderList = 2L,
    browser.download.manager.showWhenStarting = FALSE,
    browser.helperApps.neverAsk.saveToDisk = file_mime))

  RSelenium::checkForServer()
  RSelenium::startServer()
  remDr <- remoteDriver(extraCapabilities = fprof)
  remDr$open()
  return(remDr)
}

# Initial login
gesis_login <- function(remDr,
                        user = getOption("gesis_user"),
                        pass = getOption("gesis_pass")) {

  remDr$navigate("https://dbk.gesis.org/dbksearch/gdesc.asp")
  remDr$findElement(using = "id", value = "loginContainer")$clickElement()

  remDr$findElement(using = "name", "user")$sendKeysToElement(list(user))
  remDr$findElement(using = "name", "pass")$sendKeysToElement(list(pass))
  remDr$findElement(using = "id", "login")$clickElement()

}

# Go to download page
gesis_download <- function(remDr, study_id, filetype) {

  url <- paste0("https://dbk.gesis.org/dbksearch/SDesc2.asp?ll=10&notabs=1&no=",
                study_id)

  remDr$navigate(url)

  # Click filename to download .dta file
  file_to_download <- sprintf("//a[contains(text(), '%s')]", filetype)
  remDr$findElement("xpath", )$clickElement()

  # Input purpose and terms of use
  remDr$switchToWindow(remDr$getWindowHandles()[[1]][2])

  # Only check "accept terms of purpose" if unchecked
  try(if(remDr$findElement("name",
      "projectok")$getElementAttribute("checked")[[1]][1] != "true") {
      remDr$findElement("name", "projectok")$clickElement()
  }, silent = TRUE)

  remDr$findElement("xpath", "//option[@value='1']")$clickElement()
  remDr$findElement("xpath", "//input[@value='Download']")$clickElement()

  # Close Download window and switch back to first window
  remDr$closeWindow()
  remDr$switchToWindow(remDr$getWindowHandles()[[1]])
}
