# week 4
# principal component analysis, cluster analysis, r + markdown

library(tidyverse) # data manipulation
library(rio) # data import/export
library(cluster) # :)
library(factoextra) # visualizations for pca, cluster...
library(corrplot) # visualize correlations

# github.com/bdemeshev/icef_r4finance_2022
# the script is there!

# Handbook of Stat Analysis using R
?HSAUR::heptathlon

h = HSAUR::heptathlon
glimpse(h)

cor_mat = cor(h) # correlation
corrplot(cor_mat)

corrplot(cor_mat, order = 'hclust')

corrplot(cor_mat, order = 'hclust', addrect = 3)

str(h)

h7 = select(h, -score)
glimpse(h7)

# principal component analysis?


# we standardize original variables (!)
# we create new variables (artificial) as linear combinations of old variables
# max variance view: new variables (principal components) have maximal variance
# max average R^2 view: new variables have maximal average R^2 if you predict
# every old variable using new variables.


?prcomp

comps = prcomp(h7, scale. = TRUE)
comps$x # new variables

fviz_pca_ind(comps)

# hurdles_i = a + b pc1_i: R^2_1
# highjump_i = a + b pc1_i: R^2_2
# ...
# run800m_i = a + b pc1_i: R^2_7
# 0.637 = (R^2_1 + ... + R^2_7) / 7

# hurdles_i = a + b pc1_i + c pc2_i: R^2_1
# highjump_i = a + b pc1_i + c pc2_i: R^2_2
# ...
# run800m_i = a + b pc1_i + c pc2_i: R^2_7
# 0.637 + 0.171 = (R^2_1 + ... + R^2_7) / 7


fviz_pca_ind(comps, repel = TRUE)

# the main plot
fviz_pca_biplot(comps, repel = TRUE)

# weights of every original variable in principal components
comps$rotation

fviz_eig(comps, addlabels = TRUE)
fviz_contrib(comps, axes = 1, choice = 'var')

fviz_contrib(comps, axes = 1, choice = 'ind')

# let's start from the end :)
# k-means clustering: *creating* a new variable

# we standardize original variables (!)
# 1. we assign labels of clusters randomly
# 2. we calculate centers of clusters
# 3. we reassign labels by choosing cluster with closes center
# for each observation
# go to step 2.

?kmeans

h7scaled = mutate(h7, across(hurdles:run800m,
                             ~ (.x - mean(.x)) / sd(.x)))
h7scaled

h7_kmeans = kmeans(h7scaled, centers = 3)

h7_kmeans

h7_kmeans$cluster

h7_augmented = mutate(h7, cluster = h7_kmeans$cluster)
h7_augmented

fviz_cluster(h7_kmeans, data = h7scaled)


fviz_nbclust(h7scaled, kmeans, method = 'wss')

# hierarchical clustering

# 1. calculate distances between observations
# 2. we collapse two closest observations into one cluster
# (one new point with average coordinates)
# go to step 2

h7dist = dist(h7scaled, method = 'euclidean')
h7dist

fviz_dist(h7dist)

# k nearest neighbors: predict existing variable y
# classification / regression

h7hier = hcut(h7dist, k = 4)
