library(glue)
library(httr)
library(jsonlite)


resp <- GET("https://api.coindesk.com/v1/bpi/currentprice.json")
content(resp, as="text")

