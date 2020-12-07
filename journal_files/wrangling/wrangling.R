library(tidyverse)
library(vroom)
library(data.table)
library(tictoc)

col_type_ass <- list(
  id           = col_character(),
  type         = col_integer(),
  name_first   = col_character(),
  name_last    = col_character(),
  organization = col_character()
)

assignee_tbl <- vroom(
  file       = "assignee.tsv", 
  delim      = "\t", 
  col_types  = col_type_ass,
  na         = c("", "NA", "NULL")
)

col_type_patass <- list(
  patent_id    = col_character(),
  assignee_id  = col_character(),
  location_id  = col_character()
)

patent_assignee_tbl <- vroom(
  file       = "patent_assignee.tsv", 
  delim      = "\t", 
  col_types  = col_type_patass,
  na         = c("", "NA", "NULL")
)

col_types_pat <- list(
  id = col_character(),
  type = col_character(),
  number = col_character(),
  country = col_character(),
  date = col_date("%Y-%m-%d"),
  abstract = col_character(),
  title = col_character(),
  kind = col_character(),
  num_claims = col_double(),
  filename = col_character(),
  withdrawn = col_double()
)

patent_tbl <- vroom(
  file       = "patent.tsv", 
  delim      = "\t", 
  col_types  = col_types_pat,
  na         = c("", "NA", "NULL")
)

col_types_uspc <- list(
  uuid         = col_character(),
  patent_id    = col_character(),
  mainclass_id = col_character(),
  subclass_id  = col_character(),
  sequence     = col_integer()
)

uspc_tbl <- vroom(
  file       = "uspc.tsv", 
  delim      = "\t", 
  col_types  = col_types_uspc,
  na         = c("", "NA", "NULL")
)




class(assignee_tbl)
setDT(assignee_tbl)
setnames(assignee_tbl, "id", "assignee_id")

class(patent_assignee_tbl)
setDT(patent_assignee_tbl)

class(patent_tbl)
setDT(patent_tbl)
setnames(patent_tbl, "id", "patent_id")

class(uspc_tbl)
setDT(uspc_tbl)




tic()
combined_data <- merge(x = assignee_tbl, y = patent_assignee_tbl, 
                       by    = "assignee_id", 
                       all.x = TRUE, 
                       all.y = FALSE)
toc()

tic()
combined_data2 <- merge(x = combined_data, y = patent_tbl, 
                       by    = "patent_id", 
                       all.x = TRUE, 
                       all.y = FALSE)
toc()


# 1
patent_dominance <- combined_data[,.(count = .N), by = .(assignee_id, organization)][order(-count)][1:10]

# 2
innovation_award <- combined_data[lubridate::year(date) == "2019",.(count = .N), by = .(assignee_id, organization)][order(-count)][1:10]

# 3
topcompany <- combined_data2[,.(count = .N), by = .(assignee_id, organization)][order(-count)][1:10]
top5 <- combined_data[mainclass_id != ""][assignee_id %in% c("org_pCbqlmAg8wlWzoi18ITD", "org_lyNcyopxnfjHQb0gRGu5", "org_eAKK85fawH0NS7AdXOig", "org_ONzMjdbZXiKfw4L0cXl6", "org_8WujSDQFoxF1D6UMqVCV", "org_pCbqlmAg8wlWzoi18ITD", "org_dfvuIWENawcU6lTd1Z3w", "org_eAKK85fawH0NS7AdXOig", "org_OrmhECOcsM3rq5b7Pxfe"), .(number = .N), by = .(mainclass_id, organization)][order(-number)][1:5]

