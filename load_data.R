# Use data.table package

library(data.table)

library(tidyverse)
# Get all file names
list_csv_files = list.files(path = "data/")
list_csv_files = paste("data/", list_csv_files, sep="")
# Drop the sp500.csv
list_csv_files = list_csv_files[-which(list_csv_files=="data/sp500.csv")]

# Read all csv files into one df.
df = readr::read_csv(list_csv_files, id = "tick")
# Change the tick column to match its company
df$tick = sub("data/", "", df$tick)

df$tick = sub(".csv", "", df$tick)

stock_symbol = readr::read_csv("data/sp500.csv")
stock_symbol
# Sample query: count all days of records for each company.
df |> group_by(tick) |> summarise(n=n()) |> print()
df |>
  filter(Date == min(Date)) |>
  print()

df |>
  filter(tick=="AAPL") |>
  ggplot(aes(x = Date, y = Close)) +
  geom_line() 



