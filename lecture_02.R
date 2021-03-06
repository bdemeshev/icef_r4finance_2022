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
# ts cut by year
# no seasonal effects

# github.com/bdemeshev/icef_r4finance_2022


gg_lag(d, y)
# y_t versus y_{t-1}
# y_t versus y_{t-2}
# ...
gg_lag(d, b)


gg_subseries(d, y)
gg_season(d, y)

# ARMA, ARIMA model? (yes)
# ETS (exponential smoothing) model? (no)
# THETA method? (no)

# SARIMA(1,1,1)-(2,0,1)[12]

# ARIMA(1, 0, 2)
# (1 - a_1 L) (y_t - mu) = (1 + b_1 L + b_2 L^2) u_t
# u_t ~ white noise, N(0; sigma^2)

# y_t ~ ARIMA(1, 1, 2)     <=>   Delta y_t ~ ARIMA(1, 0 ,2)
# (1 - a_1 L) (1 - L) y_t = (1 + b_1 L + b_2 L^2) u_t
# u_t ~ white noise, N(0; sigma^2)
# (1 - L)y_t = Delta y_t

# SARIMA(1,1,1)-(2,0,1)[12]: (non-seas)-(seasonal)[periodicity]
# (1,1,1): 1 coef in AR, 1 order of difference, 1 in MA
# (2,0,1): 2 coefs in SAR, 0 order of seas diff, 1 in SMA
# (1 - c_1 L^12 - c_2 L^24)(1 - a_1 L) (1 - L) y_t =
# = (1 + b_1 L) (1 + d_1 L^12) u_t
# R will estimate c_1, c_2, a_1, b_1, d_1, sigma^2


d

nrow(d)
tail(d, 10)

train = filter(d, date < ymd('2007-12-01'))
tail(train)
nrow(train)

# you specify the model

# automatic ARIMA selection: Khandakar-Hyndman procedure
# 1. KPSS test to check whether we need to go from y_t to Delta y_t
# done twice
# 2. Seasonality "force" is calculated.
# We check whether we need to go from y_t to (1 - L^12) y_t
# STL decomposition is used
# done twice
# 3. A pack of stationary ARMA models is estimated
# the best is selected via AIC
# Forecasting principles and practice, Hyndman

# ARMA(1,1) = SARIMA(1, 0, 1)-(0, 0, 0)[12]
# automatic one

mod_y = model(train,
      arma11 = ARIMA(y ~ 1 + pdq(1, 0, 1) + PDQ(0, 0, 0)),
      auto = ARIMA(y))
mod_y
report(mod_y$arma11[[1]])
# (1 - (-0.3919)L) (y_t - (0.2120)) = (1 + 0.0150L) u_t

report(mod_y$auto[[1]])
?ARIMA

glance(mod_y)

fcst = forecast(mod_y, h = '2 years') # h = 24
fcst

autoplot(fcst)

autoplot(fcst, d)

accuracy(fcst, d)

# how combine models?
# Strategy 1: decompose time series into components
# use different models for components
# Strategy 2: average forecasts from some models

more_mods = mutate(mod_y, new = (arma11 + auto) / 2)
fcst = forecast(more_mods, h = '2 years') # h = 24

accuracy(fcst, d)

# break

# marriages in Russia
#

url = 'https://github.com/bdemeshev/om_ts/raw/main/data/marriages_original.xls'
m = import(url)

m2 = import(url, skip = 2)
m2

colnames(m2)
colnames(m2)[1:3] = c('region', 'unit', 'period')

glimpse(m2)

unique(m2$unit) # the same value for all observations :)
m3 = select(m2, -unit)

glimpse(m3)
# melt
# icicle
# pivot_longer | pivot_wider

m4 = pivot_longer(m3, cols = `2006`:`2021`, names_to = 'year', values_to = 'total')
# 2006 + 2015 vs `2006` + `2015`
glimpse(m4)
m4

unique(m4$period)
m5 = filter(m4, !str_detect(period, '-')) # no '-' in the column 'period'
m5
unique(m5$period)

dictionary = tibble(period = unique(m5$period), month_no = 1:12)
dictionary

m6 = left_join(m5, dictionary, by = 'period')
m6

m7 = select(m6, -period)
m7

?separate

m8 = separate(m7, col = 'region',
              into = c('code', 'name'),
              sep = ' ',
              extra = 'merge')
m8

m9 = mutate(m8,
    date = yearmonth(paste0(year, '-', month_no)))
m9

m10 = select(m9, -year, -month_no)
m10

m11 = mutate(m10, code = as.numeric(code))

# omit missing observations
m12 = na.omit(m11) # na = not available observations

# total: actual time series
# date: index
# code, name: key

marr = as_tsibble(m12,
          index = date, key = c('code', 'name'))
marr

rf = filter(marr, code == 643)
gg_tsdisplay(rf, total)


# compare some models using train-test split, CV
tail(rf)

train = filter(rf, date < ymd('2018-10-01'))
tail(train)

models = model(train,
      snaive = SNAIVE(total),
      auto = ARIMA(total),
      auto_ln = ARIMA(log(total)),
      sarima111_111 = ARIMA(total ~ 0 + pdq(1, 1, 1) + PDQ(1, 1, 1)),
      theta_ln = THETA(log(total)),
      theta = THETA(total) # a strong player for monthly ts
      )
glance(models)

report(models$auto[[1]])
# (4,1,1): 4 coefs in AR, 1 nonseas difference, 1 coef in MA
# (0,1,1): 0 coefs in SAR, 1 seas difference, 1 coef in SMA
# equation:
# (1-(-0.0753)L-0.1091L^2-0.2707L^3-(-0.2134)L^4)(1-L)(1-L^12)y_t =
# = (1 + (-0.8800)L)(1 + (-0.8360)L^12) u_t

fcst = forecast(models, h = '3 years')
fcst


filter(fcst, .model == 'auto_ln')


autoplot(filter(fcst, .model == 'auto'),
         filter(rf, date > ymd('2015-01-01')))

autoplot(fcst, rf) # too much to plot :)

# MASE = mean absolute scaled error
# MAE = mean absolute error
accuracy(fcst, rf) %>% arrange(MAE)

more_mods = mutate(models, top3 = (auto_ln + theta + auto) / 3)
fcst = forecast(more_mods, h = '3 years')
accuracy(fcst, rf) %>% arrange(MAE)
# 3 years - long horizon

# cross validation for short term (1 month ahead) forecasts

fcst = forecast(models, h = '1 month')
fcst

nrow(train)
sliding_train = slide_tsibble(rf, .size = 153, .step = 1)
filter(sliding_train, .id == 20)


models = model(sliding_train,
               snaive = SNAIVE(total),
               auto_ln = ARIMA(log(total)),
               theta = THETA(total) # a strong player for monthly ts
)
# 3 years = 36 months
# 36 training samples
# 36 training sample x (approx) 100 ARIMA models ~ 3600 models
glance(models)

fcst = forecast(models, h = '1 month')
accuracy(fcst, rf)
accuracy(fcst, rf) %>% arrange(MAE)

# Forecasting principles and practice, Hyndman
