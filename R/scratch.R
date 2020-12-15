library(dbplyr)
library(dplyr, warn.conflicts = FALSE)
data("gtcars", package = "gt")
glimpse(gtcars)

con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
copy_to(con, gtcars)

gtcars2 <- tbl(con, "gtcars")
gtcars2

lf <- lazy_frame(gtcars)

# can use dplyr 1.0.0 `across()`
lf %>%
  group_by(mfr) %>%
  summarise(across(starts_with("mpg"), mean, na.rm = TRUE))

# generate the sql code
mpg_summary <- gtcars2 %>%
  group_by(mfr) %>%
  summarise(across(starts_with("mpg"), mean, na.rm = TRUE)) %>%
  arrange(desc(mpg_h))

# preview the query
mpg_summary %>% show_query()

# execute
mpg_summary %>% collect()

# lazy frame is an easy way to just preview the SQL queries
lf <- lazy_frame(gtcars)

# relocate lets you move columns around
lf %>% relocate("year") %>%
  select(1:3) # select the first three cols

# programmatically rename columns
lf %>% rename_with(toupper)

# slice_* functions ungrouped

lf %>% #lf to view the SQL
  select(c(1:5, "msrp")) %>%
  slice_max(msrp, n = 5)

gtcars2 %>%
  select(c(1:5, "msrp")) %>%
  slice_max(msrp, n = 5)

# slice_* functions grouped
gtcars2 %>%
  select(c(1:5, "msrp")) %>%
  group_by(bdy_style) %>%
  slice_max(msrp, n = 5)

