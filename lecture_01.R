# 1-10: 6
# 10-100: 6
# 100+: 1

# use your personal computer

# install: R, Rstudio
# colab.to/r

# teams link:
# https://teams.microsoft.com/l/team/19%3aLFCQSVhyV3Kc5M1mahRnWIOfvg8ERsPmcc8lh8a5He81%40thread.tacv2/conversations?groupId=c2a4dea1-a50e-4ad2-9a77-68bbd4d315a2&tenantId=21f26c24-0793-4b07-a73d-563cd2ec235f

# code:
# 1icu208

# tidyverse, fpp3, ...
# install package just once: Tools - Install packages -
# we attach package everytime we use it

# small details:

# 1. Windows Q: "Install packages from source?"
# A: No.

# 2. Do not save environment in Rdata, do not restore it.

# 3. Problems with local character.
# Always use UTF-8 encoding for scripts, data, ...

# github.com/bdemeshev/icef_r4finance_2022
# all the scripts and link to join ms teams

library(tidyverse) # data manipulation
library(rio) # import/export
library(fpp3) # time series

# how to work with tables?
demo_table = tibble(x = c(7, 6, NA, 4),
                    hi = c(5, 8, 10, 4))
demo_table

a = 5 # i prefer this style
b <- 5 # the style your may encounter
a == b

# create a new variable
d2 = mutate(demo_table, ln_x = log(x), ln_hi = log(hi))
d2

d3 = mutate(d2, text = c('aaaaa', 'ooooo', 'hedgehog', 'apple'))
d3

d4 = mutate(d3, bad = c(3, 4, 5))
d4 = mutate(d3, good = 7)
d4

d5 = mutate(d4, good = cos(x))
d5

# how to remove some columns or some observations?

# let's filter observations!
d6 = filter(d5, x > 5, hi > 5) # rows that satisfy two conditions
d6
d7 = d5[c(1, 3), ] # rows number 1 and 3 from d5
d7
d5
d8 = select(d5, x, ln_x, good)
d8
d9 = select(d5, -good) # every column from d5 except good
d9

10:20

d5[1:3, 2:5] # rows from 1 to 3, columns from 2 to 5

d5[, 2:5] # all rows, columns from 2 to 5

# the code is not only executed but is also read later (!)
# we prefer names to column numbers

# try to write code with style
# two rules to start:
# 1. put spaces around each binary operation
# 2. put a space after a comma
5+6 +    7  +5+ 323+ 23 # bad guy style
5 + 6 + 7 + 5 + 323 + 23 # HMQ style

# how to join two tables? Привет!

d5

new = tibble(x = c(21, 22), hi = c(-6, 5), text = c('hi', 'hihi'))
new

# bind rows!
all = bind_rows(d5, new)
all


# join by some column
weight = tibble(what = c('hedgehog', 'apple'),
              kg = c(5, 0.1))
weight

full = left_join(d5, weight,
                 by = c('text' = 'what'))
full
?left_join

# how to get help?
?mutate
# google: R mutate function
# stats.stackexchange.com: questions about algorithms, models
# stackoverflow.com: programming
# rdrr.io


# import - export
getwd()

setwd("/home/boris/Downloads")

export(full, 'full.csv') # simplest one
export(full, 'full.dta') # for stata
export(full, 'full.sav') # spss
export(full, 'full.xlsx') # excel

full2 = import('full.csv')
full
full2

glimpse(full)
glimpse(full2)

# some plots
?import
d = diamonds
d

# two common plots: histograms and scatter plots

# grammar of graphics
# link variables and aesthetics of the plot

p = ggplot(data = d, aes(x = carat, y = price)) +
  geom_point()


p

p + labs(title = 'Price of diamonds')

p + labs(title = 'Price of diamonds',
         x = 'Weight of a diamond (carats)')

p + labs(title = 'Price of diamonds',
         x = 'Weight of a diamond (carats)',
         y = 'Price of a diamond (dollars)')

p + labs(title = 'Price of diamonds',
         x = 'Weight of a diamond (carats)',
         y = 'Price of a diamond (dollars)',
         subtitle = 'source: R dataset diamonds')


p2 = ggplot(data = d, aes(x = carat, y = price / 1000)) +
  geom_point()

p2 + labs(title = 'Price of diamonds',
         x = 'Weight of a diamond (carats)',
         y = 'Price of a diamond (thousands of dollars)',
         subtitle = 'source: R dataset diamonds')

p2 + labs(title = 'Price of diamonds',
          x = 'Weight of a diamond (carats)',
          y = 'Price of a diamond (thousands of dollars)',
          subtitle = 'source: R dataset diamonds') +
      theme_light()


p3 = ggplot(data = d, aes(x = carat, y = price)) +
  geom_hex()

p3 + labs(title = 'Price of diamonds',
          x = 'Weight of a diamond (carats)',
          y = 'Price of a diamond (thousands of dollars)',
          subtitle = 'source: R dataset diamonds') +
  theme_light()


set.seed(777) # initial condition of random number generator
d_sample = sample_n(diamonds, 500)

p4 = ggplot(data = d_sample, aes(x = carat, y = price / 1000)) +
  geom_point()

best = p4 + labs(title = 'Price of diamonds',
          x = 'Weight of a diamond (carats)',
          y = 'Price of a diamond (thousands of dollars)',
          subtitle = 'source: R dataset diamonds, subset of 500 out of 53000 obs') +
  theme_light()
best


p5 = ggplot(data = d, aes(x = log(carat),
                          y = log(price))) +
  geom_hex()

p5 + labs(title = 'Price of diamonds',
          x = 'Log weight of a diamond (carats)',
          y = 'Log price of a diamond (dollars)',
          subtitle = 'source: R dataset diamonds') +
  theme_light()

library(patchwork) # organize many plots one near another
(p + p2) / p3
ggsave('plot.png', dpi = 300)


ggplot(data = diamonds, aes(x = carat)) +
  geom_histogram()

# regression model

library(estimatr) # lm_robust()

# non robust standard errors
model_a = lm(data = diamonds,
        log(price) ~ log(carat) + x + y + z)
summary(model_a)
# hat log(price) = 8.04 + 1.56 log(carat) + 0.069 x + 0.024 y - 0.049 z


# robust standard errors
model_b = lm_robust(data = diamonds,
             log(price) ~ log(carat) + x + y + z)
summary(model_b)
# hat log(price) = 8.04 + 1.56 log(carat) + 0.069 x + 0.024 y - 0.049 z

# two parts of the course
# mine: 4 lectures

# grading: my part: datacamp.com
# two short courses there (one course ~ 4-5 hours of work)
# I recommend two courses, but you are free to change them

# Dean Fantazzini




