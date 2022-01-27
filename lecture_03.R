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

# github.com/bdemeshev/icef_r4finance_2022
report(mods$ets_aaa[[1]])
# b_t = b_{t-1} + 0.05039968 u_t, b_0 = -1.993292
# u_t ~ iid N(0; 98008.68)
# s_t = s_{t-4} + 0.5352046 u_t, s_0 ...
# ell_t = ell_{t-1} + b_{t-1} + 0.4036547  u_t, ell_0 = 4487.557
# y_t = ell_{t-1} + b_{t-1} + s_{t-4} + u_t

fcsts = forecast(mods, h = '4 years')
fcsts

aaa_fcsts = filter(fcsts, .model == 'ets_aaa')
autoplot(aaa_fcsts, aus_train)

report(mods$auto_ets[[1]])


mam_fcsts = filter(fcsts, .model == 'auto_ets')
autoplot(mam_fcsts, aus_train)

aaa_cmpnts = components(mods$ets_aaa[[1]])
aaa_cmpnts
autoplot(aaa_cmpnts)

# decomposition model
# which model is used to decompose ts?
# which model is used for every component of ts?

# decompose by ETS(MAM)
# ARMA(1, 1) for remainder
# SNAIVE for seasonal
# ETS(MAN) for trend

dec_formula = Electricity ~ error('M') + trend('A') + season('M')
dec_formula
components(mods$auto_ets[[1]])

# for simplicity I will use STL decomposition

mods2 = model(aus_train,
      snaive = SNAIVE(Electricity),
      dec_model = decomposition_model(
        STL(Electricity ~ season(window = 10)),
        ETS(season_adjust ~ error('M') + trend('A') + season('N')),
        SNAIVE(season_year)
        ))

mods2
report(mods2$dec_model[[1]])

fcst2 = forecast(mods2, h = '4 years')
accuracy(fcsts, aus_production) %>% arrange(MASE)

accuracy(fcst2, aus_production)


?decomposition_model





