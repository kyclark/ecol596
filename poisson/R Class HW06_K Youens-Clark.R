#
# Calculate and plot Poisson distrubution
# for different values of lambda
# Ken Youens-Clark <kyclark@email.arizona.edu>
# March 4, 2016
#

library(ggplot2)

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

#
# Plot the combined data frames using both points and lines
# Differentiate the lambda values by color
#
ggplot(data=dfs, aes(x=k, y=p, col=lambda)) + geom_point() + geom_line()