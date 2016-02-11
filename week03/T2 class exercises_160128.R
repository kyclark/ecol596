#=========================================================================================
# Class exercises to accompany Tutorial 2: Indexing
#=========================================================================================

# << Warm-ups: first session >> ----------------------------------------------------------

# (1) Make a character vector called 'biomes' containing the unique biome names in glop.
data.dir = "~/work/ecol596w/data/"
setwd(data.dir)
glop = read.csv("glopnet.csv")
biomes = unique(glop$BIOME)
biomes

# (2) A loop to see a histogram of leaf mass-per-area (lma) data for each biome.

for (b in biomes) {
  #--Make a subset of glop with only the biome corresponding to 'b'.
  sub.glop <- glop [glop$BIOME==b, ]
  #--Use hist() to make a histogram of the 'log.lma' data in the subsetted dataframe.
  # ***
  hist(sub.glop$log.LMA, main = b)
}

# (3) Add a 'title' argument to hist() in the above loop, depositing the biome name in the
# graph title.


# (4) Can you figure out how to add to that code to make it also loop through each trait
# column, creating a histogram for each trait for each biome?


# << Tutorial 2 Part 2 >> ----------------------------------------------------------------

# (1) Try to index in glop to show the log.ll and biome columns together, just for the two
# biomes "ALPINE" and "TUNDRA".



# << Advanced problems >> ----------------------------------------------------------------

# (1) Create an object that stores the result of a regression analysis between log.lma and
# log.ll in glop, making LMA the predictor variable. Use the function lm().

# (2) Use summary() to see the summary stats from the linaear model. Figure out how to
# access the r-squared value by indexing.

# (3) Figure out how to access the slope and intercept values from the regression by
# indexing.

# (4) Make a scatter plot of those two variables against each other.

# (5) On a new line of code, use abline() to add the regression line from your linear
# model to the plot.

# (6) Make a title that labels (in plain text) and provides the slope and rsq values by
# indexing them.

# (7) Make a for-loop that compares log.lma to a handful of other trait columns, running
# a regression one by one, storing slope, intercept, and rsq values in objects, plotting
# the scatter plot, adding the line, and making titles that reflect the slope and rsq for
# each graph.

