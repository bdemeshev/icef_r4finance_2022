# Hi, everyone! :)

# Week 2.1.

# Let's work with time series!

# If you want to join then use access code :)

library(tidyverse) # data manipulations
library(fpp3) # time series models
library(rio) # import/export of data

# ctrl + enter | cmd + enter to run a line (selection)

# Create time series from scratch

set.seed(777)
data = tibble(y = rnorm(100, mean = 0, sd = 1),
              b = cumsum(y))
data

# year-month-day (ymd)
data$date = ymd('2000-05-01') + months(1:100)
data

# b_t = sum_{i=1}^t y_i

# two popular formats to store time series:
# Old (but good): ts format
# + a lot of code (!)
# - for regular time series
# Modern (but less known): tsibble format
# + much more flexible!
# - less known

# Launch teams. Login with your HSE account. "Join a team".
# Enter: 1icu208


data2 = mutate(data, date = yearmonth(date))
data2

d = as_tsibble(data2, index = date)
d

# plots for time series!
gg_tsdisplay(d, y)
# y_t versus t
# sample ACF
# sample Corr(y_t, y_{t-k}) versus k
ACF(d, y)
# sample Corr(y_t, y_{t-6}) = -0.165






