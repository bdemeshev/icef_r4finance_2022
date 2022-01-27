library(tidyverse) # data manipulations
library(rio) # import/export
library(fpp3) # forecasting

aus_production

autoplot(aus_production, Electricity)

aus_train = filter(aus_production, Quarter <= yearquarter('1980Q1'))
autoplot(aus_train, Electricity)

mods = model(aus_train,
    ets_aaa = ETS(Electricity ~ error('A') + trend('A') + season('A')),
    ets_ana = ETS(Electricity ~ error('A') + trend('N') + season('A')),
    snaive = SNAIVE(Electricity),
    auto_arima = ARIMA(Electricity),
    ets_azz = ETS(Electricity ~ error('A')), # trend = A, Ad, M, Md, N; season = A, M, N
    auto_ets = ETS(Electricity),
    ets_log = ETS(log(Electricity)))


