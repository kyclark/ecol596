#=========================================================================================
# Class exercises to accompany Tutorial 2: Indexing
#=========================================================================================

# << DATASETS >>
# Call in glopnet.csv as data frame 'glop', and make the following changes.
colnames (glop) <- tolower (colnames (glop))
colnames (glop) [ncol(glop)-1] = "ca.ci"
colnames (glop) [names(glop)=="species"] = "epithet"
glop$species <- paste (glop$genus, glop$epithet, sep="_")
glop$ll <- 10^glop$log.ll

# << Warm-ups: first session >> ----------------------------------------------------------

#**Note that you should convert all 'glop' column names to lowercase, or otherwise adjust
# column references here.

# (1) Make a character vector called 'biomes' containing the unique biome names in glop.
biomes <- unique (glop$biome)

# (2) A loop to see a histogram of leaf mass-per-area (lma) data for each biome.
for (b in biomes) {
  #--Make a subset of glop with only the biome corresponding to 'b'.
  sub.glop <- glop [glop$biome==b, ]
  #--Use hist() to make a histogram of the 'log.lma' data in the subsetted dataframe.
  hist (sub.glop$log.lma)
}

# (3) Add a title to each graph using the hist() argument 'main', depositing the biome
# name in the graph title.
for (b in biomes) {
  #--Make a subset of glop with only the biome corresponding to 'b'.
  sub.glop <- glop [glop$biome==b, ]
    #--Use hist() to make a histogram of the 'log.lma' data in the subsetted dataframe.
  hist (sub.glop$log.lma, main=b)
}

# (4) Can you figure out how to add to that code to make it also loop through each trait
# column, creating a histogram for each trait for each biome?


# << Warm-ups: second session >> ---------------------------------------------------------

# (1) Which glop biome contains the leaves with the longest leaf lifespan?
glop [which (glop$ll == max(glop$ll, na.rm=T)), "biome"]

# (2) What is the species with the longest leaf lifespan?
glop [which (glop$ll == max(glop$ll, na.rm=T)), "species"]


# << Tutorial 2 Part 2 >> ----------------------------------------------------------------

# (1) Try to index in glop to show the log.ll and biome columns together, just for the two
# biomes "ALPINE" and "TUNDRA".
glop [glop$biome %in% c("ALPINE","TUNDRA"), c("log.ll","biome")]

# (2) Take this vector 'forests' of forest-type biomes. If unique(glop$biome) produces a
# vector of all the biomes, how would you add an index to that to get all the biomes that
# aren't in 'forests'? Use that to make a vector 'not.forests' of non-forest biomes.
forests <- c("TEMP_RF","TROP_RF","TEMP_FOR","TROP_FOR","BOREAL")
not.forests <- unique (glop$biome) [! unique(glop$biome) %in% forests]

# (3) Make a new column in glop called 'biome.type'. Start with empty text "". Then make
# the entries corresponding to forest rows equal "forests" and non-forest rows equal
# "not.forests". Index those positions using our vectors from (2).
glop$biome.type <- ""
glop$biome.type [glop$biome %in% forests] = "forests"
glop$biome.type [glop$biome %in% not.forests] = "not.forests"

# (4) Use ggplot2 to view a histogram of leaf lifespans ('ll'), colored by 'biome.type'.
# > ggplot (data=***, aes (x=***, y=***, fill=***)) + geom_histogram (position="dodge")


# (5) Let's see if the relationship between leaf investment time ('log.ll') and invested
# material per photosynthetic area ('log.lma') differs between biome types. Instead of the
# 'fill' argument, use 'color', and use geom_point().


# (6) Get a linear regression line added to that, by adding the function
# geom_smooth(method="lm").


# (7) What could be driving the difference? Try the plot by growth form 'gf' instead.


# Looks like the woody plants fall together, with grasses and herbs on either extreme.

# (8) Do another, but indexing in the data argument to only include the growth forms "G"
# and "H".



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

