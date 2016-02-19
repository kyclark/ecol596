#=========================================================================================
# R class HW05
#=========================================================================================

# << INFORMATION >>
# - This exercise is based on teaching materials from Brian McGill's site, and also slides
# from Max Li's statistics seminar (included with this exercise). More details at
# stats.brianmcgill.org.
# - This uses the data 'birdsdiet.csv' from McGill's site.
# - The object is to practice testing the assumptions behind general linear models, making
# data alterations to better satisfy assumptions, and practice indexing results from
# linear model outputs and creating summary tables.
# - You can do this assignment without understanding the stats. But the accompanying PDF
# has a few slides with bullet points that are worth skimming through, especially the last
# slide which explains R's standard set of linear model plots.

# EXAMPLES for two techniques you haven't learned yet:
# - Making a data frame from scratch with some pre-defined columns and some empty ones:
results <- data.frame (lm = c("lm1","lm2","lm3"), p = NA)
results
# - Hint for viewing a re-ordered data frame with order().
tmp <- data.frame (one=c("a","c","b"), two=c(32,4,10))
tmp
order (tmp$one)
# Hmm, maybe you could use the result from that for indexing somehow...
tmp[order(tmp$one),]
# << DIRECTORIES >>


# << DATASETS >>
#--With an internet connection, you should be able to call the birdsdiet.csv dataset
# directly into your RAM (where R stores objects) as a data frame.
#birds <- read.csv ("http://130.111.193.18/stats/birdsdiet.csv")
birds <- read.csv("~/work/ecol596w/data/birdsdiet.csv")

#-----------------------------------------------------------------------------------------
# Exercise
#-----------------------------------------------------------------------------------------

# 1) First, make the headers lowercase so they're easier/faster to type.
colnames(birds) = tolower(colnames(birds))

# 2) Put a period before each "abund" to separate from max and avg. Use gsub() to redefine
# the column names, replacing "abund" with ".abund". See ?gsub for help.
for (i in grep("abund", colnames(birds))) {
  colnames(birds)[i] = gsub("abund", ".abund", colnames(birds)[i])
}
colnames(birds)

# 3) "Pelicans" is misspelled in the 'family' column. Use gsub() to efficiently change
# "Pelecans" to "Pelicans" in the family column without having to index it.
birds$family = gsub("Pelecans", "Pelicans", birds$family)

# 4) Run a linear model lm() calculation of 'max.abund' (y) against 'mass' (x). Store it
# in an object named 'lm1'.
lm1 = lm(max.abund ~ mass, data=birds)

# 5) Make a scatter plot of 'mass' on the x and 'max.abund' on the y. For base-R, use
# plot(x,y). Add the regression line to it using abline(lm1). (Just execute the abline()
# code on a new line line after plot() has been executed. The line should appear overlaid
# on the scatterplot.)

plot(x = birds$mass, y = birds$max.abund, xlab = "Mass", ylab = "Abundance")
abline(lm1)

# 6) Get some more information by plotting the linear model with plot(lm1). This produces
# several graphs. You need to keep hitting RETURN in the console to make all of them. You
# can scroll back and forth through them with the arrows in the Plots window.
plot(lm1)

# 7) The Normal Q-Q plot suggests our residuals (deviation of the data from the
# statistical estimate) are not normally distributed. Take a look at the distribution of
# the residuals by putting them in hist(). Use str() on 'lm1' to see how to index the
# residuals.
str(lm1)
hist(lm1$residuals)

# 8) Check the independence of our residuals by plotting residuals 1 through the
# second-to-last residual, against residuals 2 through the last residual. I.e., offset
# them by plotting 1 through length-1 against 2 through length. Add a regression line to
# that. If they are independent from each other, there should be a shallow slope.

plot(lm1$residuals[1:(length(lm1$residuals)-1)], lm1$residuals[2:length(lm1$residuals)])
abline(lm1$residuals[1:(length(lm1$residuals)-1)], lm1$residuals[2:length(lm1$residuals)])

# 9) See if log transforming both variables with log() helps.
# - Make a new linear model object 'lm2' with results for log transformed data.
birds$max.abund.log = log(birds$max.abund)
birds$mass.log = log(birds$mass)
lm2 = lm(max.abund.log ~ mass.log, data=birds)

# - Make another scatter plot with log transformed data, add the regression line.
plot(x = birds$mass.log, y = birds$max.abund.log, xlab = "Mass", ylab = "Abundance", main = "Log mass/abund")
abline(lm2)

# - Check the histogram of residuals.
hist(lm2$residuals)

# - Plot R's automatic series of linear model plots for 'lm2'.
plot(lm2)

# - Check the independence of residuals (as in #8).
plot(lm2$residuals[1:(length(lm2$residuals)-1)], lm2$residuals[2:length(lm2$residuals)])
abline(lm2$residuals[1:(length(lm2$residuals)-1)], lm2$residuals[2:length(lm2$residuals)])

# 10) In our Leverage plot, which point is shown as the most outlying (i.e. worst Cook's
# distance; closest to dashed lines)? The number next to that point is the row number in
# the data frame.
# - What group of birds is it?
birds[32,"family"]

# - What makes that data an outlier? Use the order() function to see if 'mass' or
# 'max.abund' of this bird group falls on the extreme high or low end for the dataset.
birds[order(birds$mass), c("mass", "family")]

# >> pelicans are very heavy birds

# 11) Try again with row 32 excluded. (But note that in the real world, identifying and
# excluding "outliers" should only be done only with excellent justification, and the
# exclusion and reasoning should be reported in the publication.)
# - Make the linear model 'lm3'.

no.pelicans = birds[-32,]
lm3 = lm(max.abund.log ~ mass.log, data=no.pelicans)

# - Plot the scatter plot and regression line.
plot(x = no.pelicans$mass.log, y = no.pelicans$max.abund.log, xlab = "Mass", ylab = "Abundance", main = "Log mass/abund, No Pelicans")
abline(lm3)

# - Check the lm plots.
plot(lm3)

# 12) Now make a results table called 'results' to deposit some comparative results from
# our different approaches above.
# - Make it a data frame with columns for the model number (like our lm1, lm2...),
# p-value, r-squared value, regression slope, regression intercept, and a 'data.treatment'
# column with notes on the relevant choices made for each analysis, e.g., "log
# transformed", etc.
results = data.frame(model.number = c("lm1", "lm2", "lm3"), 
                     pvalue=NA, r2value=NA, slope=NA, intercept=NA, 
                     data.treatment=c("nothing", "log", "outlier.removed"))

# - Deposit the p, r.sq, and regression coefficients into the data frame by indexing in
# the linear model objects, and pointing them at the right positions in the results table.
# (No manually entering them into the results table; make the cells in the results table
# equal to the indexed objects in the linear models.)


# Deposit the p-values. (signif() function truncates to specified sig digs.)
lm1.res = summary(lm1)
lm2.res = summary(lm2)
lm3.res = summary(lm3)

results[results$model.number == "lm1", "pvalue"] = lm1.res$coefficients[4]
results[results$model.number == "lm2", "pvalue"] = lm2.res$coefficients[4]
results[results$model.number == "lm3", "pvalue"] = lm3.res$coefficients[4]

# Deposit the r-sq values.
results[results$model.number == "lm1", "r2value"] = lm1.res$r.squared
results[results$model.number == "lm2", "r2value"] = lm2.res$r.squared
results[results$model.number == "lm3", "r2value"] = lm3.res$r.squared

# Deposit the slope values.
results[results$model.number == "lm1", "slope"] = lm1.res$coefficients[2]
results[results$model.number == "lm2", "slope"] = lm2.res$coefficients[2]
results[results$model.number == "lm3", "slope"] = lm3.res$coefficients[2]

# Deposit the intercept values.
results[results$model.number == "lm1", "intercept"] = lm1.res$coefficients[1]
results[results$model.number == "lm2", "intercept"] = lm2.res$coefficients[1]
results[results$model.number == "lm3", "intercept"] = lm3.res$coefficients[1]

