avg_prices = function(data) {
  data |>
    group_by(tick) |>
    summarise(avg = mean(Close))
}