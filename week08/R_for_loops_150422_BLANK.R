#=========================================================================================
# For-loops in R: A tutorial on iteration of analysis with the for() function. Any
# questions, contact Ty Taylor: tytaylor@email.arizona.edu
#=========================================================================================

# << INTRODUCTION >> ---------------------------------------------------------------------

# Looping = iteration. When you need to repeat a similar task over a set of elements,
# looping is the ticket. If you're learning R, but you've had some practice with your own
# data, your scripts probably have blocks of code lines that do almost the same thing,
# only to different inputs or with slightly different options. Whenever you see that
# repeated code, you should be thinking looping. The first looping method to learn is the
# for-loop. After the learning custom functions, we'll get to 'apply' functions, which are
# like loops, but more compact and faster. However, it's best to learn for loops first,
# and they will always have their place.

#=========================================================================================
# Tutorial contents
#=========================================================================================

#  Part 1:  Basic principles of iterations using for loops
#  Part 2:  Simple examples
#  Part 3:  Growing vectors; multiple references with 'i'
#  Part 4:  Nested for loops
#  Part 5:  Flow control with if, else, else if, and next

#=========================================================================================
# Introductory code
#=========================================================================================

# << PACKAGES >> -------------------------------------------------------------------------
#--Load the package 'ggplot2' (must be installed first).
library (ggplot2)

# << DIRECTORIES >> ----------------------------------------------------------------------

#--Define the path to your data directory with a text string ending with "/".
dat.dir <- "~/work/ecol596/data"

#--Make a figures folder somewhere and define the path in the object 'fig.dir'.
fig.dir <- "~/work/ecol596/figures"

# << DATASETS >> -------------------------------------------------------------------------

#--Read in the glopnet data as data frame 'glop'.
glop <- read.csv(file.path(dat.dir, "glopnet.csv"))

#--Read in the output from the Taxanomic Name Resolution Service, which read all the
# glopnet species names, and matched them to a plant name database. We'll use it to get
# family names into 'glop'.
glop.tnrs <- read.csv(file.path(dat.dir, "glopnet.tnrs.csv"))

# << CLEAN AND MERGE DATA >> -------------------------------------------------------------

#--To make things easier, make these changes to 'glop': make the column names lowercase,
# and change the second to last column name to "ca.ci".
colnames (glop) <- tolower (colnames (glop))
colnames (glop) [ncol(glop)-1] = "ca.ci"

#--Change the 'species' column name to 'epithet', then make a new column 'species' equal to
# paste()ing 'genus' and 'epithet' with sep="_".
colnames (glop) [which (colnames (glop) == "species")] = "epithet"
glop$species <- paste (glop$genus, glop$epithet, sep="_")

#--Replace spaces in the glop.tnrs$Name_submitted column with "_" to match glop$species
# so we can merge by species names.
glop.tnrs$Name_submitted <- gsub (" ","_",glop.tnrs$Name_submitted)

#--Merge the family names from 'glop.tnrs' into 'glop' by their common species names.
glop <- merge (glop, glop.tnrs [c("Name_submitted", "Accepted_family")], by.x="species",
               by.y="Name_submitted", all.x=T)

#--Rename 'Accepted_family' to 'family'.
colnames (glop) [colnames (glop) == "Accepted_family"] = "family"


#=========================================================================================
# Part 1: Basic principles of iterations using for loops
#=========================================================================================

#-----------------------------------------------------------------------------------------
# Basic structure of a for loop
#-----------------------------------------------------------------------------------------

for (ith.thing in multiple.things) {
  # Do something
  # Repeat a number of times equal to the number of things in 'multiple.things'
}

# Looping is VERY flexible. Your loop might alter each ith.thing in multiple.things. Or
# that might just be a way to standardize the number of times you do something to some
# entirely different object.

# ith.thing can be a number, a character string, a whole data frame... As long as your
# syntax is correct, creativity is the only limit to what your loop can do.

#--Some tools:
# Most common: make 'i' equal to each index number of some object.
for (i in 1:length (vector1)) {  }

# An equivalent shortcut for the above:
for (i in seq_along (vector1)) {  }

# It doesn't have to be 'i', and it doesn't have to be a number.
for (cn in colnames (data.frame1)) {  }

#-----------------------------------------------------------------------------------------
# Squiggly brackets { } make a temporary new 'environment'
#-----------------------------------------------------------------------------------------

# - Your 'environment' in R is where things are stored (see the Environment tab in the
# upper right window of RStudio to see stored objects).
# - Squiggly brackets { } make a temporary new environment, nested within your global
# environment.
# - This is important because in a for-loop, results won't get printed into your console
# unless you use print() to export them out of the loop environment (examples below).
# - Any objects created in the loop DO automatically get saved in the global environment.
# - Note that these rules differ a bit in the environment created by { } in custom
# functions, covered in the next tutorial. In that case, objects created in the custom-
# function environment are not automatically saved to the global environment, and you have
# to use return() to export to global.


#=========================================================================================
# Part 2: Simple examples
#=========================================================================================

#-----------------------------------------------------------------------------------------
# Iterating across numbered indices of a vector
#-----------------------------------------------------------------------------------------

#--Example vector.
vec <- c(55, 44, 33, 22, 11)

#--Use seq_along() to make i equal to 1 through 5 (the length of vec).
# - For each element in vec, make it equal to itself times 2. But NOTE: since math is
# vectorized in R, you could just do vec=vec*2, but this is just to get a feel for the
# for-loop structure.
for (i in seq_along(vec)) {
  vec[i] = vec[i] * 2
}

#-----------------------------------------------------------------------------------------
# Enclosing multiple lines of code in a loop.
#-----------------------------------------------------------------------------------------

# A for-loop can be as long as you want it to be. You could enclose an entire long R
# script in the squiggly brackets of a loop.

# To make several lines, enter inside the brackets and hit RETURN. RStudio will indent to
# show you that you are still inside the brackets. Here's an example:

for (i in seq_along(vec)) {
  a = vec[i] * 2
  b = a*10
  print(b)
}

# NOTE: See what 'a', 'b', and 'i' are. All of them have been saved to the global
# environment. Each will have the last identity it took on in the loop.
a
b
i

#-----------------------------------------------------------------------------------------
# Iterating across the numeric contents of a vector
#-----------------------------------------------------------------------------------------

#--In this case, i becomes each element of the vector, instead of each position index.
# Just to illustrate simply, make a vector v <- c(1,10,100). Make a for loop that prints
# each element of 'v' divided by 3. Note that the print() function is required to make R
# show you the result of each iteration.

v = c(1,10,100)

for (n in v) {
  print(n/3)
}

# NOTE: The print() function is required to make R show you the result of each iteration.

# POP QUIZ 1: Make a vector 't.col.nums' of the trait column numbers in glop() that
# correspond to traits 'log.ll', 'log.lma', 'log.amass', and 'log.aarea'. Get the column
# numbers using which() and %in%.
t.col.nums = which(colnames(glop) %in% c('log.ll', 'log.lma', 'log.amass', 'log.aarea'))
 


# Now make a for-loop that loops across t.col.nums, using them to index in glop and print
# the number of non-NA entries in each of those columns.

for (i in t.col.nums) {
  print(length(which(!is.na(glop[[i]]))))
}


#-----------------------------------------------------------------------------------------
# Using words
#-----------------------------------------------------------------------------------------

#--Let's get the number of unique datasets, biomes, genera, and species in 'glop'. Make a
# vector with the column names (a character vector). Loop across the names, using each one
# to index in 'glop', printing the number of unique entries in each column.
colnames = c('dataset', 'biome', 'genus', 'species')

for (cn in colnames) {
  print(paste(cn, "=", length(unique(glop[[cn]]))))
}
  

#--Make a vector of unique biome names from 'glop', then print the mean log leaf life span
# (log.ll) for each biome. *Don't forget to deal with NAs with argument na.rm=T.
biome.list = unique(glop$biome)

for (b in biome.list) {
  print(b)
  print(mean(glop[glop$biome == b, "log.ll"], na.rm=T))
}


# POP QUIZ: Which biomes produced NaN results? Why did they return NaN?



#=========================================================================================
# Part 3: growing vectors; multiple references with 'i'
#=========================================================================================

#-----------------------------------------------------------------------------------------
# Growing vectors: v <- c (v, ith.new.element)
#-----------------------------------------------------------------------------------------

# Growing vectors is a very common purpose of for loops. Start with an empty vector, then
# in each iteration, make it equal to a vector containing itself, and the i'th new
# element.

#--Make a vector containing the mean log leaf lifespan for each biome in 'glop'. This is
# the same as the previous exercise, except instead of printing the answer, you're storing
# it, and adding it to a growing vector.

biome.means = c()
for (b in biome.list) {
  mean.i = mean(glop[glop$biome == b, "log.ll"], na.rm=T)
  if (! is.nan(mean.i)) {
    biome.means = c(biome.means, mean.i)
  }
}





#-----------------------------------------------------------------------------------------
# Multiple references with 'i'; thinking flexibly about 'i'.
#-----------------------------------------------------------------------------------------

# Think of the 'i' in a for loop as a temporary object, which is recreated as many times
# as is specified by 'in'. You can do anything you want with that temporary object. Or,
# you don't have to do anything with it. You could just use 'i' as a counter.

#--Use a for loop to print 10 sets of random numbers drawn from a normal distribution with
# mean 5 and sd 2 (using rnorm()).

for (i in 1:10) {
  print(rnorm(n=1, mean=5, sd=2))
}

# Of course, that is the same as putting your rnorm() function inside of rep() as:


# But if you had multiple lines of code you wanted repeated 10 times, you would have to
# use a loop to count (or use rep() with a multiple-line custom function).

#--Now, modify the above loop so you have the 'mean' argument of rnorm() equal 'i', and
# 'sd' equal to i+2.

for (i in 1:10) {
  print(rnorm(n=1, mean=5, sd=i+2))
}

#--Let's make a 'biome.results' data frame, where we can deposit summary statistics about
# each biome. Start with a two-column data frame containing the unique biome names and a
# column 'mean.log.ll' filled with NAs.
glop$ll = 10 ^ glop$log.ll

biome.results = data.frame(biome = biome.list, mean.ll = NA)


#--Now, loop across the 'biome.list' character vector.
# - Use 'i' (or whatever you name it) to index in both the 'glop' data frame, and in
# 'biome.results'.
# - Get the mean of 'log.ll' for each biome (with NAs removed), and store it in an object
# 'mean.i'.
# - Deposit 'mean.i' in its corresponding place in 'biome.results'.

for (bn in biome.list) {
  mean.i = mean(glop[glop$biome == bn, "ll"], na.rm=T)
  biome.results[biome.results$biome == bn, 'mean.ll'] = mean.i
}



# Take a look at your results.


#=========================================================================================
# Part 4: Nested for loops
#=========================================================================================

#-----------------------------------------------------------------------------------------
# Nested for loop basic structure
#-----------------------------------------------------------------------------------------

# Sometimes you have multiple data groups, and within each group there are sub-groups, or
# conditions that you want to analyze independently. In these cases, you might want to use
# a nested for loop. Structurally, just put the inner loop inside the outer loop, like so:

for (i in groups) {
  for (j in sub.groups.or.conditions) {
    # Do some stuff.
  }
}

# That loop will run length(groups)*length(sub.groups.or.conditions) times, because for
# every 'i', it goes through every 'j'.

# You can also "do some stuff" inside the outer loop before or after the inner loop
# finishes, like this:
for (i in groups) {
  # Do some stuff in the outer loop.
  for (j in sub.groups.or.conditions) {
    # Do some stuff in the inner loop.
  }
  # Do some more stuff in the outer loop, maybe using things created in the inner loop.
}

#--Make these two vectors to loop through for a simple illustration.
letters.vec <- c("a", "b", "c")
numbers.vec <- c(1,2,3,4,5)

#--Now, let's make a nested for loop that just prints the iteration variables in the order
# in which they are run.







# Notice how R printed the first 'i'="a", then it printed every 'j', one at a time, then
# moved onto 'i'="b". So it entered the outer loop, and completed the entire inner loop
# before advancing in the outer loop, then the inner loop was repeated, etc.

#--What hapens if we put the first print command in the second for loop?







# "a" was repeated, but again, the outer loop did not advance until the inner loop was
# complete. And the inner loop repeated length(letters.vec) times.

#-----------------------------------------------------------------------------------------
# Nested for loop example with data
#-----------------------------------------------------------------------------------------

# Let's get a little data-count information about our glopnet data that will be useful for
# considering analyses and statistical power. We'd like to analyze the differences between
# biomes in leaf-mass-per area. But we know that deciduous and evergreen trees will be
# very different, so we should compare D's to D's and E's to E's among biomes. First, we
# should see which biomes and which phenologies (D or E) have enough data to do this.

# So, in English, for each biome, and for each leaf phenology, we just want a count of
# non-NA data. We should put this in a table.

#--Make a data frame 'lma.counts' with three columns: biome, phenology, count. The 'biome'
# column should have each unique biome name repeated twice, one set associated with
# 'phenology' equal to "E" and the other with 'phenology' equal to "D". Set 'count'=NA. We
# can use our 'biome.list' object created earlier (vector of unique biome names).

lma.counts = data.frame(
  biome = rep(biome.list, 2),
  phenology = c(rep("E", length(biome.list)), rep("D", length(biome.list))),
  count = NA
)



#--Now the nested for loop. We'll translate the English explanation above into R.
# - We can use the 'biome.list' to define the outer loop.
# - Use a vector with "E" and "D" to define the inner loop.
# - Use our 'i' and 'j' for indexing both in 'glop' and in 'lma.counts'.
# - Use length() to count, !is.na() to test for non-NAs, and which() to only count TRUE
# answers.


for (b in biome.list) {
  for (phen in c("E", "D")) {
    count.i = length(which(!is.na(
      glop[glop$biome == b & glop$decid.e.green == phen, "log.lma"]
    )))
    lma.counts[lma.counts$biome == b & lma.counts$phenology == phen, "count"] = count.i
  }
}







# NOTE: by looping across actual values (like "DESERT"), we could make sure our indexing
# always went to the right place. If we indexed by position, we might get things out of
# order and not know it.

#-----------------------------------------------------------------------------------------
# Testing segments of for loops without having to complete the whole loop
#-----------------------------------------------------------------------------------------

# Loops can get complicated. It's nice to be able to test individual lines of code. This
# is easy. Just make a temporary definition of 'i', or 'j', or whatever.

# To test the line in the above loop that counts non-na data, without running the whole
# loop, give a definition to 'b' and 'phen', say "TEMP_RF" and "E". Then run the line of
# code.






#=========================================================================================
# Part 5: Flow control with if, else, else if, and next
#=========================================================================================

# NOTE: Each section here uses a simplified example to teach the syntax. See the last
# section in Part 5 for a realistic data example.

# "Flow control" is like controlling your path through a flow chart. From some starting
# point, actions are taken, and bifurcation points are reached where a test determines
# which path from a set of alternate flow paths to take next.

# In a for loop, the code runs repeatedly through a flow path. When you want to add
# bifurcation points to the flow path, and have your code be dynamically responsive to
# the outcomes of the tests at those points, use the techniques taught below.

# NOTE: All these functions also work outside of loops. But they are most common in loops
# and in custom functions.

#-----------------------------------------------------------------------------------------
# if (test) { what to do if the test passes }
#-----------------------------------------------------------------------------------------

# The basic structure of if() is much like for(). It looks like:
# if (logical test) { what to do if test result is TRUE }

#--Try this simple example to illustrate. Make object 'x' equal 1. Use if() to print "it's
# true!" if x+x is equal to 2.


# now redefine 'x' to equal 2 and do the same if(){} statement.


# Nothing printed! That's because you only gave R something to do if the answer was TRUE.

#--Make sure you see exactly what R sees here. Copy the above if(){} statement. Replace
# the logical test with the logical value TRUE. This is the 'equivalency principle' in
# operation.

# And then with FALSE:


# You see, R does not need if() to contain a test in the way you think of it. R will
# evaluate ANYTHING that returns a single logical value, i.e. TRUE or FALSE. As with
# everything else in R, when you have the actual mechanics in mind, you can be more
# creative than your intuition initially suggests.

#--Don't forget all the other ways to work with logicals that we covered in the indexing
# tutorial. Like & (and) and | (or):



# and the bang ! operator (invert logical)


#-----------------------------------------------------------------------------------------
# if (test) { } else { what to do if the test fails }
#-----------------------------------------------------------------------------------------

# else{} is used to tell R what to do if the if() function fails (returns FALSE). else{}
# has no parenthetical test like if(), it is only followed by squiggly brackets {} and it
# MUST directly follow the closing squiggly bracket of if(){} on the same line. (Re-read
# that last clause.)

#--Let's see how this works in a loop. Loop through the numbers 1 through 3, testing
# whether 'i' equal to 2, and printing "it's true!" if it's true. Every time, print "test
# i complete", with 'i' taking on the actual number.







# Examine those results. R completed the for loop each time, but only did the stuff in
# if(){} when it passed.

#--Now, use else{} to print "it's false!" when the if() test fails.







#--To illustrate a common syntax problem with if(){}else{}, execute the two versions of
# code below
if (1 == 2) {
  print ("it's true!")
} else { print ("it's false!") }

# versus:
if (1 == 2) {
  print ("it's true!")
}
else { print ("it's false!") }

# Note that if wrapped inside of a for loop, the second version will work, but inside of a
# custom function, or out on its own, the second version will cause an error. It's best to
# just make a habit of doing it the first way.

#-----------------------------------------------------------------------------------------
# if (test.1) { } else if (test.2) { }
#-----------------------------------------------------------------------------------------

# Imagine your flow path (of analysis/actions) coming to a test point:
# - With if(){}, something is **either done, or not done**, and the analysis moves on.
# - With if(){}else{}, some **action is always taken**, and the action depends on which of
# two mutually exclusive outcomes occured, i.e. the test passed or it failed.
# - Use if(){} else if (){} when you want the choice of subsequent flow paths to depend on
# **multiple non-mutually exclusive outcomes**.

# Like else {}, else if (){} must follow the last } of if(){}. Other than that,
# else if(){} is just like if(){}.

#--Modify the previous for loop to either print "i equals 1", "i equals 2", or "i does not
# equal 1 or 2", when each particular statement is true.








#-----------------------------------------------------------------------------------------
# next = "Skip to the next iteration"
#-----------------------------------------------------------------------------------------

#--Copy the above loop, and replace the print command for if(i==1) with 'next' (no quotes)








# When R hits 'next', it skips everything downstream of that point, and moves on to the
# next iteration of the loop. Imagine you have some very computation-heavy code below a
# check-point, where if some condition is satisfied, the rest of the analysis will not be
# useful. You can save computation time by using 'next' to skip the rest and move on to
# conditions that provide useful results.

#-----------------------------------------------------------------------------------------
# any() and all(): are there any TRUE answers? are all answers TRUE?
#-----------------------------------------------------------------------------------------

# An if() test requires a single TRUE or FALSE to be returned. any() and all() are useful
# ways to collapse many logical evaluations into one.

#--Make a loop that tests whether any, all, or none of a test set of plant families occur
# in a given biome in glopnet.
# - Loop across our 'biome.list' created above (vector of unique biome names in the
# glopnet dataset).
# - Have the loop print "All of the test "families occur in biome i", "Not all, but at
# least one of the test families occurs in biome i", or "None of the test families occur
# in biome i". But replace 'i' with the actual biome name.
# - Make sure the loop advances instead of duplicating results where, e.g., all() and
# any() would both return TRUE.
# - Since the test is the same for each condition, save the logical test at the top of the
# loop in an object 'test'.














#-----------------------------------------------------------------------------------------
# A useful, realistic example of flow control in loops!
#-----------------------------------------------------------------------------------------

#--We know there are strong global relationships between leaf traits in the glopnet
# dataset. But how do these differ among biomes? Let's make a loop that, for each biome,
# plots leaf mass per area (log.lma) against area-based nitrogen content. (log.narea),
# includes p and rsq values in the title, and exports the plots to file. But we want it to
# skip biomes that have fewer than 30 paired data points to compare.

# One quick fix first: rename biome GRASS/M to GRASS_M, so the "/" doesn't mess things up
# when we try to name the exported file by the biome name.



#--Start the loop through all the biomes in 'glop'.
for (biome in biome.list) {
  #--Make a small, subsetted data frame that's easy to work with.

  #--Subset again to cases where data occurs for both traits using complete.cases().

  #--Use if(){next} to make it skip the rest of the loop if there are fewer than 3 rows
  # remaining in 'dat' after the complete.cases() subsetting.


  #--Do a linear regression on x=log.lma and y=log.narea.

  #--Save the p, rsq, intercept, and slop values to objects, truncated to 2 significant
  # digits.





  #--Use ggplot2 to make the scatter plot.

  # Add the regression line.

  # paste0() together a title indicating the biome, p, and rsq value.

  # Add the title to the plot.

  # Print the plot in RStudio.


  #--Now export the plot to your figures directory created at the top of the tutorial,
  # using the png() function to make it a ".png" image file. Name the file with the biome
  # name.

  # Just print() again, now that the png 'graphics device' is open.

  # Close the graphics device.



# A FEW NOTES on the above analysis:
# - We did not check that species weren't repeated in this analysis. You would probably
# want to do some species averaging if there are duplicates per biome.
# - Area is included in both the x and the y axis, which will tend to increase
# correlations. Some follow-up papers to the leaf economics spectrum have attempted to
# deal with that problum, though it is not trivial.
# - The only biome that had fewer than 30 data points was DESERT. You can check that with
# this loop:
for (b in biome.list) {
  print (paste (b, length (which (complete.cases (
    glop [glop$biome==b, c('log.lma','log.narea')])))))
}




