#
# Calculate and plot Poisson distrubution
# for different values of lambda
# Ken Youens-Clark <kyclark@email.arizona.edu>
# March 4, 2016
#

library(ggplot2)
library(reshape2)

# cf. http://en.wikipedia.org/wiki/Poisson_distribution 
pdist = function (k, l) {
  (l ^ k) * exp(-l) / factorial(k)
}

dfs = data.frame()
for (lambda in c(1,4,10)) {
  #
  # Calculate y for 20 values for the given lambda
  #
  v = vector()
  for (k in 1:20) {
    p = pdist(k, lambda)
    v = c(v, p)
  }
  pois=data.frame(k=1:20, p=v, lambda=factor(lambda))
  
  dfs = rbind(dfs, pois)
}

ggplot(data=dfs, aes(x=k, y=p, col=lambda)) + geom_point(size=10) + geom_line()

#
# Alternate
#

kmax = 20
pvalues = list()
for (lambda in c(1,4,10)) {
  #
  # Calculate y for 20 values for the given lambda
  #
  v = vector()
  for (k in 1:kmax) {
    p = pdist(k, lambda)
    v = c(v, p)
  }
  pvalues[[paste0('l', lambda)]] = v
}

pois = data.frame(k=1:kmax, pvalues)
df = melt(pois, id.vars="k", variable.name="l", value.name="p")

ggplot(data=df, aes(x=k, y=p, col=l)) + geom_point() + geom_line()

add2 = function (n) { n + 2 }
#
v = lapply(c(1:kmax), pdist, c(1,4,10))

k = 1:20
df = data.frame(k=factor(k), 
                p1 = sapply(k, pdist, 1),
                p4 = sapply(k, pdist, 4),
                p10 = sapply(k, pdist, 10)
                )

