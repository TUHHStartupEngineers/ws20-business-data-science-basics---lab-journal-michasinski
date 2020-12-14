# WEBSCRAPING ----

# 1.0 LIBRARIES ----

library(tidyverse) # Main Package - Loads dplyr, purrr, etc.
library(rvest)     # HTML Hacking & Web Scraping
library(xopen)     # Quickly opening URLs
library(jsonlite)  # converts JSON files to R objects
library(glue)      # concatenate strings
library(stringi)   # character string/text processing

# 1.1 COLLECT PRODUCT FAMILIES ----

url_home          <- "https://www.rosebikes.de/"

# Read in the HTML for the entire webpage
html_home         <- read_html(url_home)

# Web scrape the ids for the families
bike_family_tbl <- html_home %>%
  html_nodes(css = ".main-navigation-category-with-tiles__tile-img") %>%
  html_attr('alt') %>%
  enframe(name = "position", value = "family_class") %>%
  mutate(
  family_id = str_glue("#{family_class}")
  )

# 1.2 COLLECT PRODUCT CATEGORIES ----

bike_category_tbl <- html_home %>%
  html_nodes(css = ".main-navigation-category-with-tiles__tile-link") %>%
  html_attr('href') %>%
  enframe(name = "position", value = "subdirectory") %>%
  mutate(
    url = glue("https://www.rosebikes.de{subdirectory}")
  ) %>%
  distinct(url)

# 2.0 COLLECT BIKE DATA ----

get_bike_data <- function(url) {
  html_bike_category <- read_html(url)

  bike_name_tbl <- html_bike_category %>%
    html_nodes('.catalog-category-bikes__title-text') %>%
    html_text %>%
    str_remove_all("\n")
  
  bike_price_tbl <- html_bike_category %>%
    html_nodes('.catalog-category-bikes__price-title') %>%
    html_text %>%
    str_remove_all("\n") %>%
    str_remove_all(" ab") %>%
    str_remove_all("ab") %>%
    # str_remove_all(" ")
  
  tibble(bike_category_tbl, bike_name_tbl, bike_price_tbl)
}

bike_category_url_vec <- bike_category_tbl %>% 
  pull(url)

bike_data_lst <- map(bike_category_url_vec, get_bike_data)
bike_data_tbl <- bind_rows(bike_data_lst)
bike_data_tbl