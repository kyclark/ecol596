#
# Sample and plot Poisson distributions for various lambdas
# As the number of sample means increases, we should see
# a normal distribution around the lambda per the 
# Central Limit Theorem
# 
# Ken Youens-Clark <kyclark@email.arizona.edu>
# March 9, 2016
#

# for "sprintf"
library(R.utils) 

# "par" is global, so save current state to restore later
old.par = par(mfrow=c(2,3))

# number of means
k = 1000

# using different lambda values
for (lambda in c(.1, 5)) {
  
  # take n-sized samples  
  for (n in c(10, 100, 1000)) {
    
    # preallocated the vector to hold the means
    v = numeric(k)
    
    # take 1K means from the Poisson distribution
    for (i in 1:k) {
      v[i] = mean(rpois(n, lambda))
    }
    
    # the histogram should be centered around the lambda value
    hist(sample(v, n), xlab="rpois", main=sprintf("n=%s, λ=%s", n, lambda))
  }
}

# restore "par"
par(old.par)