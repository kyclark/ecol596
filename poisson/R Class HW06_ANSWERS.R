#=========================================================================================
# R class HW06 ANSWER SHEET
#=========================================================================================

# << INFORMATION >>
# The aim of this assignment is to practice with for loops, and help you to undertand
# Poisson distributions and the Central Limit Theorem. See the explanatory PDF associated
# with this assignment.

# << PACKAGES >>
library (ggplot2)
library (reshape2)

#-----------------------------------------------------------------------------------------
# 1) Translate the probability mass function of the Poisson distribution into R.
#-----------------------------------------------------------------------------------------

#--Poisson PMF where 'l' is lambda and 'k' is k.
(l^k * exp(-l)) / factorial(k)

#-----------------------------------------------------------------------------------------
# 2) Loop to generate a vector of probabilities 'p' calculated from a Poisson distribution
# with lambda=1 for k=1:20.
#-----------------------------------------------------------------------------------------

#--Set lambda 'l' equal to 1.
l = 1

#--Make an empty vector 'p.l1'.
p.l1 <- c()

#--Grow the vector 'p' with probabilities calculated in the for loop.
for (k in 1:20) {
  #--Calculate the ith probability and save it.
  p.i <- (l^k * exp(-l)) / factorial(k)
  #--Add p.i to the vector of probabilities.
  p.l1 <- c(p.l1, p.i)
}

#-----------------------------------------------------------------------------------------
# 3) Combine 'p' and 'k' in a data frame 'pois' and plot with ggplot.
#-----------------------------------------------------------------------------------------

#--Make the data frame.
pois <- data.frame (p.l1, k=1:20)

#--Plot 'p' against 'k'.
ggplot (data=pois, aes (x=k, y=p.l1)) + geom_point() + geom_line() + ylab("P(X = k)")

#-----------------------------------------------------------------------------------------
# 4) Re-create the graph for lambda = 4.
#-----------------------------------------------------------------------------------------

#--Set lambda 'l' equal to 4.
l = 4

#--Make an empty vector 'p'.
p.l4 <- c()

#--Grow the vector 'p' with probabilities calculated in the for loop.
for (k in 1:20) {
  #--Calculate the ith probability and save it.
  p.i <- (l^k * exp(-l)) / factorial(k)
  #--Add p.i to the vector of probabilities.
  p.l4 <- c(p.l4, p.i)
}

#--Make the data frame.
pois <- data.frame (p.l5, k=1:20)

#--Plot 'p' against 'k'.
ggplot (data=pois, aes (x=k, y=p.l5)) + geom_point() + geom_line() + ylab("P(X = k)")

#-----------------------------------------------------------------------------------------
# 5) Combine results for l=1,4,10 into a single data frame and plot together
#-----------------------------------------------------------------------------------------

#--Generate results and data frame for l=10.
l = 10 ; p.l10 <- c()

for (k in 1:20) {
  #--Calculate the ith probability and save it.
  p.i <- (l^k * exp(-l)) / factorial(k)
  #--Add p.i to the vector of probabilities.
  p.l10 <- c(p.l10, p.i)
}

#--Put the results in separate data frames using the p-vectors generated above.
l1 = data.frame (k=1:20, l=1, p=p.l1)
l4 = data.frame (k=1:20, l=4, p=p.l4)
l10 = data.frame (k=1:20, l=10, p=p.l10)

#--Stick those data frames together with rbind().
pois <- rbind (l1, l4, l10)

#--Convert the l column to a factor so ggplot can use it to differentiate treatments.
pois$l <- as.factor (pois$l)

#--Plot with ggplot, with a separate color for each lambda.
ggplot (data=pois, aes (k, p, color=l)) + geom_point() + geom_line() + ylab ("P(X = k)")

#-----------------------------------------------------------------------------------------
# Alternatives for (5)
#-----------------------------------------------------------------------------------------

# << ALTERNATIVE 1 >> --------------------------------------------------------------------

# We've repeated the k-loop three times, each for a different lambda. You could nest that
# loop inside a lambda-loop to do them all at once. Grow the result data frame from an
# empty data frame using rbind(), just like you'd grow a vector with c().

#--Make an empty data frame.
pois <- data.frame ()

#--Start an outer loop across lambda values.
for (l in c(1,4,10)) {
  #--Inner loop across k values.
  for (k in 1:20) {
    #--Get the i'th p-value.
    p <- (l^k * exp(-l)) / factorial(k)
    #--Deposit k, l, and p into a single-row data frame.
    pois.i <- data.frame (k, l, p)
    #--rbind() pois.i with pois to grow pois.
    pois <- rbind (pois, pois.i)
  }
}

# << ALTERNATIVE 2 >> --------------------------------------------------------------------

# Use the handy function melt() in the package 'reshape2' (a companion to ggplot2) to turn
# a "wide format" data frame to a "long format" data frame for plotting with ggplot2.

#--Load reshape2 (install first).
library (reshape2)

#--Make a data frame with your k values, and a column from each vector of p values.
pois <- data.frame (k=1:20, p.l1, p.l4, p.l10)
# Take a look at pois.
pois

#--Use melt() to stack the lambda columns and repeat the k column alongside each one.
pois <- melt (pois, id.vars="k", variable.name="l", value.name="p")
# View pois.
pois

# Now you can plot with ggplot, and in this case, 'l' is already a factor.



