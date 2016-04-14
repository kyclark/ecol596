#=========================================================================================
# Custom functions: the gateway to dynamic automation in R.
#=========================================================================================
# Any questions, contact Ty Taylor: tytaylor@email.arizona.edu

# << INTRODUCTION >> ---------------------------------------------------------------------

# Custom functions were once described to me as "the brownbelt of R coding" (as in the
# martial arts brownbelt). To tap into the real power of programming, custom functions are
# a necessary basic skill. They have the same structure as built-in functions, they're
# just homemade. But they are often much much larger than built-in functions. Imagine you
# have a long script that performs a series of operations on some data, and produces a
# result, like a p-value or a graph. Imagine you want to run that whole script, but with
# some different subset of your data, or with a different argument specified in your
# statistical analysis, or on a different set of groups, or to a new dataset you just
# acquired. A custom function allows you to put all that work inside of it, and repeat
# that work over differen options or datasets by specifying those as arguments when you
# call the function. This is extremely powerful. Hopefully that will be clear by the end.

# So custom functions are good for:
# 1) Rapidly exploring many analysis options on a given dateset.
# 2) Performing similar actions/analyses on different datasets.
# 3) Custom functions are also good for doing small tasks that you find yourself repeating,
# and for which there is no built-in function in R (like my wrap_text() function that
# we'll use later, which wraps graph titles).
# 4) Rapid iteration: custom functions allow for rapid iteration of analyses when executed
# by apply() functions, which are the subject of the next tutorial.

# NOTE NEW TUTORIAL METHODS:
# 1) I'll be repeating several longer custom functions here, each time with slight
# modifications. To avoid making you repeatedly type in the same code, I have indicated
# the locations for you to write code in the BLANK script with # ***. So wherever you see
# that, that's something for you to fill in.
# 2) I have also highlighted new sections in altered custom functions by outlining with
# #~~~~~~~~~~~~. So look within those outlines for relevant additions.

#=========================================================================================
# Tutorial contents
#=========================================================================================

#  Part 1:  Custom functions basic structure
#  Part 2:  Default arguments and flow control
#  Part 3:  Return()ing objects; custom errors and warnings; source()ing your own library
#  Part 4:  Devloping from blank screen to complete function
#  Part 5:  Dynamic graph titles that track function options
#  Part 6:  Nested custom functions
#  Part 7:  ggplot2 in custom functions--its weird behavior and how to overcome it

#=========================================================================================
# Introductory code: Pull in the glopnet dataset (available with tutorials)
#=========================================================================================

# << PACKAGES >>
#--Load the package 'ggplot2' (must be installed first).
library(ggplot2)
library(R.utils)

# << DIRECTORIES >>
#--Define the path to your data directory with a text string ending with "/".
dat.dir = "~/work/ecol596/data"

# << DATASETS >> -------------------------------------------------------------------------
#--Read in the glopnet data as data frame 'glop'.
glop = read.csv (file.path(dat.dir, "glopnet.csv"))
#--Read in the output from the Taxanomic Name Resolution Service, which reads all the
# glopnet species names, and matched them to a plant name database. We'll use it to get
# family names into 'glop'.
glop.tnrs = read.csv (file.path (dat.dir, "glopnet.tnrs.csv"))

# << CLEAN AND MERGE DATA >> -------------------------------------------------------------
#--To make things easier, make these changes to 'glop': make the column names lowercase,
# and change the second to last column name to "ca.ci".
colnames (glop) = tolower (colnames (glop))
colnames (glop) [ncol(glop)-1] = "ca.ci"

#--Change the 'species' column name to 'epithet', then make a new column 'species' equal
# to paste()ing 'genus' and 'epithet' with sep="_".
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
# Part 1: Custom functions basic structure
#=========================================================================================

# The syntax for creating a custom function looks like this:
function_name <- function (arguments) {
  # code that does stuff.
}

# Note the similarities to the for loop syntax. 'function' gets highlighted blue in
# RStudio, then there are parentheses (), then squiggly brackets {}.

# As in for loops, the squiggly brackets define a temporary 'environment', the one
# belonging to the function, which is nested within the 'global environment'.
# - This is necessary so that no objects created within the function's {} get saved to the
# global environment.
# - AND it means that if you want anything to come out of the function, it has to be
# explicitly exported, e.g., with return(), print(), plot(), png(), write.csv(), etc.

# >> What are arguments?
# - Arguments are the names of objects that get defined when the user calls the function.
# - Read the above line again.
# - Those objects can be used within the function's {}, but they are never saved to the
# global environment unless the function explicitly exports them with return().

#--Simple example:
# - Make a function called 'print_sqrt' that has one argument 'x'.
# - The function should print a sentence saying "The square root of [x] is [the answer]."
# with the actual values substituted for the [ ].

print_sqrt = function (x) {
   printf("The square root of %s is %.2f.\n", x, sqrt(x))
}


# Execute those lines of code. Nothing is printed, because all you did was create the
# object 'print_sqrt'. See what class() of object that is.
print_sqrt(4)
print_sqrt(5)

# Functions are objects of class "function".

# Use a custom function in the same way you use any built-in function (review details of
# calling function arguments in the R Primer tutorial).

#--Use our print square root function for 5, and then 10, and then 1000000.

for (n in c(5,10,1000000)) {
  print_sqrt(n)
}

#lapply(c(5,10,1000000), print_sqrt)

# Note a few things:
# - 'x' is just an object. If you make a numerical object 'x' outside of the function,
# i.e. in the global environment, you could run the line inside of the funtion in
# isolation, and it would work.
# - So the code inside the {} is just a script that does work with objects. Don't mistake
# the elegance of that simplicity for limitation.
# - Notice how compactly we can explore the results of different values of 'x' since we
# isolated the code that does the work inside of a function. Now you can just concentrate
# on analyzing the results of different inputs.

#--A more interesting example:
# - Make a function 'graph_traits' that graphs the relationship (scatterplot) between any
# two numerical leaf traits for any given biome.
# - paste() together a plot title that includes the trait names and the biome used.
# - Make the arguments 'biome', 'trait.1', and 'trait.2'.

# Open the function definition.
graph_traits = function (biome, trait1, trait2) {
  #--Subset the data to the specified biome, saving to a new data frame 'dat'.
  dat = glop[ glop$biome == biome, ]
  #--Make the graph title as an object.
  title = paste0(trait1, " vs. ", trait2, " for biome ", biome, ".")
  #--Make the plot in the usual base-R way. You don't need the print() function because
  # plot() already commands export to the plotting window.
  plot(x=dat[[trait1]], y=dat[[trait2]], main=title, xlab=trait1, ylab=trait2)
}

# Execute that code to make 'graph_traits'. Try it out with 'log.lma' and 'log.narea' for
# the "ALPINE" biome.
graph_traits("ALPINE", "log.lma", "log.narea")

# STYLE NOTE: I always use a "." separator for standard object and column names, and a "_"
# separator for custom function names. Custom functions can do a lot of hidden work. With
# this distinct-looking naming convention, I can scan my code and quickly pick out where
# lots of hidden work is being done.


#=========================================================================================
# Part 2: Default arguments and flow control
#=========================================================================================

# Let's add some capability to the 'graph_traits' function.
# - We'd like to be able to plot any set of biomes instead of just one at a time.
# - We'd like to compare the strengths of different trait relationships, but we want to
# make sure we're comparing across the same sets of species with the same representation
# of biomes.

#--The 'graph_traits' function is outlined again below. Fill in the gaps with the
# following modifications:
# - Change 'biome' arg to 'biomes' with default "all". (Make sure to change any references
# to that argument in the function code as well.)
# - Add a 'complete.traits' argument with default NULL.
# - Edit the function's code as descriped in the line headings below.
# - Get rid of the 'biomes' part of the title, because as a vector it will do weird
# things. See the tutorial section on 'dynamic graph titles' to see how to neatly
# incorporate the vector of specified biome names into the title.
# - **Treat this as a POP-QUIZ, try to complete it without looking at the completed
# tutorial!

graph_traits2 <- function (trait.1, trait.2, biomes="all", complete.traits=NULL) {
  #--Subset the data to the subset of biomes if supplied. Save to a new data frame 'dat'.
  # - Because 'biomes' is a vector, you need to ask whether "all" occurs anywhere in the
  # vector, and if so, make 'dat' a subset of glop by biomes, otherwise, make dat=glop.
  
  title = sprintf("'%s' vs '%s'\nbiome=%s", trait1, trait2, paste0(biomes, collapse=', '))

  dat = if (any(biomes == "all")) glop else glop[ glop$biome %in% biomes, ]
  
  #--Subset to 'complete.traits' if specified.
  if (!is.null(complete.traits)) {
    dat = dat[complete.cases(dat[complete.traits]), ]
  }
  
  #--Make the graph title as an object. (Exclude the biome reference.)
  
  #--Make the plot in the usual base-R way. You don't need the print() function because
  # plot() already commands export to the plotting window.
  plot (x=dat[[trait.1]], y=dat[[trait.2]], main=title, xlab=trait.1, ylab=trait.2)
}

#--Test out the function with some different inputs.

graph_traits2("log.ll", "log.lma")
traits = c("log.ll", "log.lma", "log.aarea", "log.narea")
graph_traits2("log.ll", "log.lma", "all", traits)
graph_traits2("log.ll", "log.lma", "ALPINE", traits)
graph_traits2("log.ll", "log.lma", c("ALPINE", "DESERT"), traits)
graph_traits2(
  trait.2="log.lma", 
  biomes=c("ALPINE", "DESERT"), 
  trait.1="log.ll", 
  complete.traits=traits)

#=========================================================================================
# Part 3: Return()ing objects; custom errors and warnings; source()ing your own library
#=========================================================================================

#-----------------------------------------------------------------------------------------
# Return()ing objects: mechanics, realistic example, returning multiple objects.
#-----------------------------------------------------------------------------------------

# Remember that { } encloses a temporary environment. R exports no objects from that
# environment to the global environment unless explicitly directed. It will, however,
# automatically export "the value of the last evaluated expression" (see ?return) if the
# return() function is not encountered. We'll look at the mechanics a little, but let's
# just say you should usually be clear in your code and explicitly return(objects).

#--Execute the following alternatives of this little temporary function.
tmp_fun <- function (x) { x+2 }
tmp_fun (2) # returns 4

tmp_fun <- function (x) { answer <- x+2 }
tmp_fun (2) # returns nothing

# An answer was returned in the first version because it was the last thing the function
# did and the result was not stored in an object. See the next alternatives. (Remember
# that ';' separates multiple lines of code on the same line of script.)

tmp_fun <- function (x) { x+2; answer <- x+2 }
tmp_fun (2) # returns nothing because a stored object came last.

tmp_fun <- function (x) { answer <- x+2; answer+2 }
tmp_fun (2) # returns 6 because it was the value of the last evaluated expression.

#--Now with the return() function.
tmp_fun <- function (x) { answer <- x+2; return (answer) }
tmp_fun (2) # returns 4

# In such a simple function, the first version is fine. In bigger functions, I think it's
# clearest to end with a return() line. Let's do a more interesting example.

# << Jacknife estimator function >> ------------------------------------------------------

# The jacknife estimator of a parameter is obtained by eliminating one element at a time
# from the sample and estimating, say the mean, or the variance. Then take the mean of all
# the estimates. This has the effect of slightly de-valuing the weight of outliers, and
# can be used to estimate model bias.

#--Let's make a function to get a jacknife estimate of the slope of the relationship
# between two glopnet traits. An argument can define which grouping element gets removed
# one-by-one. I have lef the comments in as a guide, and OPEN and CLOSE to guide placement
# of { and }.
# OPEN FUNCTION

jack_slope = function (trait.x, trait.y, group) {
  #--Empty vector to grow with calculated slopes.
  slopes = numeric()

  for (x in c(trait.x, trait.y, group)) {
    if (!x %in% colnames(glop)) {
      return(sprintf("Can't find %s in glop", x))
    }
  }
  
  #--Loop through each element of the 'group' column, eliminating that element and getting
  # the slope of the relationships between the traits. Put it in the vector.
  for (i in unique(glop[[group]])) {
    print(i)
    # Make a subsetted dataset equal to glop, excluding rows with group==element.i or NA.
    dat = glop[!glop[[group]] == i & !is.na(glop[[group]]), ]
    # Run the linear model and add the slope to 'slopes'.
    lm.i = lm(dat[[trait.y]] ~ dat[[trait.x]])
    slope.i = lm.i$coefficients[2]
    slopes = c(slopes, slope.i)
  }
  #--Calculate the mean of all the jacknifed slopes to get the jacknife estimator.
  jack.slope = mean(slopes)
  
  #--Return the jacknife estimator of the slope.
  return (jack.slope)
}

jack_slope("foo", "bar", "baz")

#--Note how quick and intuitive it is to see what is returned from the function. Try it
# out with 'log.lma', 'log.ll', and 'species'. (It will take a few seconds.)
jack_slope ("log.lma", "log.ll", "species")

#--To store the output, point the executed function at an object. Let's save the returned
# jacknife estimate to an object 'jack.slope' in the global environment.
jack.slope <- jack_slope ("log.lma", "log.ll", "species")

# << Returning multiple objects >> -------------------------------------------------------

# Return multiple objects by putting them in a list.

# We'd like an idea of which groups are heavily weighting the overall slope of the trait
# relationship. This modification of the function returns both the overall jacknife
# estimator of the slope, and a table showing each slope for each element removed.

# Fill in the return() line and highlight and execute the new function definition.

#--The re-defined function returns two objects in a list: a value, and a table.
jack_slope <- function (trait.x, trait.y, group) {
  #--Start a table with the unique, non-NA 'group' elements to populate with slope values.
  unique.elements <- unique (glop [!is.na (glop [[group]]), group])
  table <- data.frame (rm.element=unique.elements, slope=NA)
  #--Loop through the unique.elements in the table and deposit slopes.
  for (element.i in unique.elements) {
    dat <- glop [!glop[[group]]==element.i & !is.na (glop[[group]]), ]
    lm.i <- lm (dat[[trait.y]] ~ dat[[trait.x]])
    slope.i <- lm.i$coefficients [2]
    table [table$rm.element==element.i, "slope"] = slope.i
  }
  #--Calculate the mean of all the jacknifed slopes to get the jacknife estimator.
  jack.slope <- mean (table$slope)

  #--Return the jacknife estimator of the slope and the table in a list.
  return(list(jack.slope, table))
}

#--Execute the function for 'log.lma', 'log.ll', and 'biome'.
jack_slope("log.lma", "log.ll", "biome")

# (Removal of temperate forests most strongly reduces the slope, and removal of wetlands
# most strongly increases it.)

#--You can store both outputs in a list:
jack.biome = jack_slope("log.lma", "log.ll", "biome")

# Then access each one in the usual way you index lists:

printf("est = %s\n", jack.biome[[1]])
jack.biome[[2]]

#--Since the execution of the function is equivalent to a list, you can add list indices
# directly to the end of the function call. Do this to save the table and estimator value
# to independent objects:
# ***


# NOTE: We're getting creative with jacknifing here. And creativity is both the power and
# danger of programming. Decide carefully whether you're producing publishable statistics
# or just exploratory information.

#-----------------------------------------------------------------------------------------
# Custom warnings with warning() and errors with stop()
#-----------------------------------------------------------------------------------------

# You can build in your own warnings and errors into custom functions. Note how when R
# returns a warning to you, the function is still executed. When R returns an error to
# you, the function does not execute, it fails. Custom warnings and errors in your own
# functions work the same way.

# << Warnings >> -------------------------------------------------------------------------

#--Let's modify jack_slope to give us a warning when any of the grouping elements don't
# have any paired trait data for the traits of interest. Use complete.cases() to test each
# row for paired trait data, all()==FALSE to test if all rows have NO complete.cases().
# Use warning("your warning") for the custom warning.

jack_slope <- function (trait.x, trait.y, group) {
  unique.elements <- unique (glop [!is.na (glop [[group]]), group])
  table <- data.frame (rm.element=unique.elements, slope=NA)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #--Loop through unique elements testing whether there are 0 complete cases of the traits
  # of interest for each grouping element.
  test <- c()
  for (element.i in unique.elements) {
    #--Ask whether all() results of complete.cases() are FALSE.
    test.i <- all (complete.cases (
      glop [glop[[group]]==element.i, c(trait.x, trait.y)]) == FALSE)
    test <- c(test, test.i)
  }
  #--Return a warning if any of the groups have no complete cases. ('test' is a logical
  # vector with TRUE representing biomes that had no complete cases.)

  if (any(test)) {
    warning("At least one removal group has 0 complete cases of trait data")
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  for (element.i in unique.elements) {
    dat <- glop [!glop[[group]]==element.i & !is.na (glop[[group]]), ]
    lm.i <- lm (dat[[trait.y]] ~ dat[[trait.x]])
    slope.i <- lm.i$coefficients [2]
    table [table$rm.element==element.i, "slope"] = slope.i
  }
  jack.slope <- mean (table$slope)
  return (list (jack.slope, table))
}

#--Try it out with the same settings as before.
jack_slope ('log.lma', 'log.ll', 'biome')

# NOTE: You could of course extend the warning message to list the troublesome elements.
# You could use 'test' to index the elements with no complete cases and use paste() with
# the 'collapse' argument to add them to your warning message.

# << Errors >> ---------------------------------------------------------------------------

# If you'd prefer that the function simply failed any time one of your grouping elements
# had zero complete trait cases, use stop() for a custom error. Placing tests for custom
# errors early in the function ensures that you don't have to wait for the function to
# complete much of its work before you find out that it couldn't satisfy the crieria to
# run in the first place. I will sometimes put a whole section of tests guiding custom
# errors and warnings near the top of a function.

#--Modify the function above, replacing warning() with stop().
jack_slope <- function (trait.x, trait.y, group) {
  unique.elements <- unique (glop [!is.na (glop [[group]]), group])
  table <- data.frame (rm.element=unique.elements, slope=NA)
  test <- c()
  for (element.i in unique.elements) {
    test.i <- all (complete.cases (
      glop [glop[[group]]==element.i, c(trait.x, trait.y)]) == FALSE)
    test <- c(test, test.i)
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #--Return an error if any of the groups have no complete cases. ('test' is a logical
  # vector with TRUE representing biomes that had no complete cases.)

  # ***

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  for (element.i in unique.elements) {
    dat <- glop [!glop[[group]]==element.i & !is.na (glop[[group]]), ]
    lm.i <- lm (dat[[trait.y]] ~ dat[[trait.x]])
    slope.i <- lm.i$coefficients [2]
    table [table$rm.element==element.i, "slope"] = slope.i
  }
  jack.slope <- mean (table$slope)
  return (list (jack.slope, table))
}

#--Try it again:
jack_slope ('log.lma', 'log.ll', 'biome')

# The function should fail and return this error:
# Error in jack_slope("log.lma", "log.ll", "biome") :
#   At least one removal group has zero complete cases of trait data.

#-----------------------------------------------------------------------------------------
# Source()ing your own library; the args() function
#-----------------------------------------------------------------------------------------

# You can store functions in separate scripts and call them in with source(). All source()
# does is call in a script and execute the whole thing, and the script doesn't have to be
# open in RStudio. This is particularly useful if (a) you have functions that are
# generally useful for a variety of analyses, or (b) you want to separate the 'work' from
# the 'analysis'. Aside from custom functions, I make data-cleaning scripts and source()
# them to create all the objects to analyze in a separate script.

# In the case of (b), often you'll want to do a lot of repetition of the same work with
# different options and inputs. It's nice to build your record of actual analyses of data
# in a separate script, where you can concentrate on the analysis itself as opposed to the
# labor behind it.

# Here's an example for (a): wrap_text(). The R graphing functions annoyingly do not have
# an option (that I know of) for wrapping the title text to set margins. If your title
# exceeds the size of the exported graph, it just disappears into nothingness. I made the
# wrap_text() function to solve this common problem. It is included with this tutorial,
# and put to use in Part 5.

#--Make a functions directory object 'fun.dir', pointing to the folder containing the
# wrap_text function (and end with /).
fun.dir = "~/work/ecol596/fun"
source(file.path(fun.dir, "wrap_text.R"))

#--The primary argument for source() is 'file', so just point it at the script like you'd
# call in a dataset, except don't store the output as an object.
# ***

# Look in your Environment tab in the upper right window of RStudio. The wrap_text()
# function should now be listed under the Functions heading.

#--Since you can't see the code for this function, the two best ways to get information
# about it are 1) print it in the console by executing its name, or 2) just look at the
# arguments with args().
# ***
# ***


#=========================================================================================
# Part 4: Developing from blank screen to complete function
#=========================================================================================

# Custom functions that do really interesting things get large and complex. You have to
# start thinking more abstractly about how to make the code flexible for different
# argument inputs, or even different datasets. You have to think about the downstream
# consequences of each action in the code, given the different possible inputs. This makes
# for a much more non-linear type of code development than your basic line-by-line
# sequential script. You'll move upstream and downstream, developing different sections
# and testing how they interact, starting with basic capabilities, then sweeping through
# and adding more nuance. You should think of developing a good function (or any script)
# like writing a paper: work systematically within a clear structure, refining drafts of
# each section, gradually integrating into a whole. Below are some tips for organized
# development of a custom function.

# NOTE on softcoding: You can get carried away building in too much flexibility, which
# makes the code cumbersome. Congratulate yourself when you've achieved the ability to
# softcode, then analyze when you should back off and just finish the job for the dataset
# and tasks at hand!

# >> Describe your plan in English
# IN your R script, verbally describe the purpose of the function--what it will do, what
# kind of data it will work with, the primary questions you'll answer with it, what kind
# flexibility you want it to have, what the inputs and outputs will be. Lay out in bullet
# points the sequence of tasks or actions in the code.

# >> Outline, and make it pretty!
# Immediately lay out headings and subheadings both outside of and inside of the function.
# Get an arguments description section started. Give the function a name and open up its
# squiggly brackets { }. Inside those brackets, lay out the general section headings. Put
# To Do lists in them. This turns the overwhelming blank page into something to work with!
# Use good style and make the structure pretty! Why? Because you'll WANT to work with it!
# Why do you think babies are cute? Evolution figured out that mothers would be more
# likely to help them grow to maturity!

# >> Object-directed code
# Keep in mind what aspects you want to be flexible, and make sure the code will
# accommodate that, e.g., by indexing with objects instead of hard names or numbers.

# >> Temporary arguments
# As you work out what the arguments will be, temporarily define them as objects so that
# you can work with the code inside the function as if it were a regular script running
# in the global environment. The function code IS a regular script in the global
# environment if you are running lines of code between the { }. Have a section devoted to
# temporary arguments outside of the function while you develop.

#-----------------------------------------------------------------------------------------
# Function: graph_traits. Here's how I would lay out the description and code.
#-----------------------------------------------------------------------------------------

# << INFORMATION >> ----------------------------------------------------------------------
# This function produces a scatterplot of relationships between any two leaf trait columns
# for any set of specified biomes in the glopnet data. It has the capability to limit
# analyses to a subset of the data with no missing values for a given set of traits. This
# increases comparability between different trait relationships.

# << ARGUMENTS >> ------------------------------------------------------------------------
# < argument > (default) Description.

# < biomes > ("all") Character vector of biomes to include in the analysis. Default will
# incorporate all biomes.

# < trait.1 > () Character: column name of the x-axis trait.

# < trait.2 > () Character: column name of the y-axis trait.

# < complete.traits > (NULL) Character vector of trait columns. Function will subset the
# data frame to rows containing data in all of the 'complete.traits' columns using
# complete.cases().

# << TEMPORARY ARGUMENTS >> --------------------------------------------------------------
# *This is only used during devlopment. Delete what function is complete.
# I would change these arguments to different combinations of alternatives as I test the
# code inside the function.

biomes = c("TEMP_RF","DESERT","ALPINE")
trait.1 = "log.ll"
trait.2 = "log.lma"
complete.traits = c("log.ll","log.lma","log.narea")

# << FUNCTION >> -------------------------------------------------------------------------
graph_traits <- function (biomes="all", trait.1, trait.2, complete.traits=NULL) {
  #--Subset the data to the subset of biomes if supplied. Save to a new data frame 'dat'.
  if (! "all" %in% biomes) { dat <- glop [glop$biome %in% biomes, ] } else { dat <- glop }
  #--Subset to 'complete.traits' if specified.
  if (!is.null (complete.traits)) { dat <- dat [complete.cases (dat[complete.traits]), ] }
  #--Define the graph title text for biomes choices.
  if ("all" %in% biomes) {
    title.biomes <- "All" } else {
      title.biomes <- paste (biomes, collapse="; ") }
  #--Make the graph title as an object.
  title <- paste0 (trait.1, " vs. ", trait.2, " for biome(s): ", title.biomes, ".")
  #--Make the plot in the usual base-R way. You don't need the print() function because
  # plot() already commands export to the plotting window.
  plot (x=dat[[trait.1]], y=dat[[trait.2]], main=title, xlab=trait.1, ylab=trait.2)
}

# << TEST SECTION >> ---------------------------------------------------------------------
# *Temporary section for testing the function as a completed function.

graph_traits ("all", "log.ll", "log.lma", c("log.ll","log.lma","log.aarea","log.narea"))

graph_traits (c("ALPINE","DESERT"), "log.aarea", "log.narea", NULL)


#=========================================================================================
# Part 5: Dynamic graph titles that track function options.
#=========================================================================================

# It's really useful to have the choices that went into the analysis reflected in the
# graph title, especially when you are producing many graphs to compare. This can be like
# your figure legend. As your subsetting options become more dynamic, your graph title has
# to be more dynamic to accommodate. This can be done with a little creative use of loops,
# if statements, and paste().

#-----------------------------------------------------------------------------------------
# The 'collapse' argument of paste()
#-----------------------------------------------------------------------------------------

#--paste() together the following vector of biomes, setting the 'collapse' argument to
# "; ".
biomes <- c("ALPINE","TEMP_RF","DESERT")
paste(biomes, collapse=";")

library(R.utils)
printf("Problems biomes are %s.\n", paste0(biomes, collapse=", "))


# ***

#--Let's use if() and paste() with its 'collapse' argument to allow our title to reflect
# our 'biomes' choices. (Fill in the blanks below.)
graph_traits <- function (biomes="all", trait.1, trait.2, complete.traits=NULL) {
  #--Subset the data to the subset of biomes if supplied. Save to a new data frame 'dat'.
  if (! "all" %in% biomes) { dat <- glop [glop$biome %in% biomes, ] } else { dat <- glop }
  #--Subset to 'complete.traits' if specified.
  if (!is.null (complete.traits)) { dat <- dat [complete.cases (dat[complete.traits]), ] }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #--Define the graph title text for biomes choices.
  
  title.biomes = if ("all" %in% biomes) "All" else paste(biomes, collapse="; ")
  title = sprintf("%s vs %s for biomes: %s.", trait.1, trait.2, title.biomes)


  #--Make the graph title as an object.
  # ***
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #--Make the plot in the usual base-R way. You don't need the print() function because
  # plot() already commands export to the plotting window.
  plot (x=dat[[trait.1]], y=dat[[trait.2]], main=title, xlab=trait.1, ylab=trait.2)
}

#--Try it out.
graph_traits ("all", "log.ll", "log.lma", c("log.ll","log.lma","log.aarea","log.narea"))
graph_traits (c("ALPINE","DESERT"), "log.aarea", "log.narea", NULL)

#-----------------------------------------------------------------------------------------
# Adding carriage returns to break long titles into multiple lines.
#-----------------------------------------------------------------------------------------
# SECTION NET YET CREATED

#-----------------------------------------------------------------------------------------
# wrap_text custom function.
#-----------------------------------------------------------------------------------------
# SECTION NOT YET CREATED: But, this function is explained and used in the next section.

#=========================================================================================
# Part 6: Nested custom functions, nested environments and the '...' argument.
#=========================================================================================

# The main unique considerations for nesting a function inside of another are (1) keep
# track of the nesting of environments, and (2) know how to pass down arguments through
# the hierarchy. The '...' argument in outer functions is a trick for (2).

# Just as the { } nest a temporary environment inside the global environment, they can
# nest a local environment inside of another function's local environment. So anything
# created in an inner function must be explicitly exported. If return() is used, the
# objects go to the outer local environment, not to the global.

# << local environment returns >> --------------------------------------------------------

# To demonstrate, take a look at the wrap_text() function, copied below without comments
# for compactness. It has a function defined within it, break_text(), which takes a line
# of text and breaks it in two. break_text() is called (used) in the code beneath it. What
# happens is lines of text are assessed to see whether they are longer than 'wrap.length'
# (the wrap_text() argument that sets the maximum number of characters allowed per line),
# and if so, then break_text is used to break it neatly at the nearest space before
# 'wrap.length'. Then the remaining fragment is assessed and the process repeats until all
# fragments are <= 'wrap.length'. (That conditional repetition is accomplished with the
# 'while' operator.)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wrap_text <- function (text, wrap.length=60) {
  break_text <- function (text.frag, wrap.length) {
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    spaces <- sapply (1:(wrap.length+1), function (i) {
      i.char <- substr (text.frag, i, i)
      if (i.char == " ") { return (i) } else { return (NA) } })
    break.char <- spaces [max (which (!is.na (spaces)))]
    frag1 <- substr (text.frag, 1, break.char - 1)
    frag2 <- substr (text.frag, break.char + 1, nchar (text.frag))
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    return (c(frag1, frag2))
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }
  if (nchar (text) <= wrap.length) {
    return (text) } else {
      all.frags <- text
      while (nchar (all.frags [length (all.frags) ]) >= wrap.length) {
        last.frag <- all.frags [length (all.frags)]
        new.frags <- break_text (last.frag, wrap.length)
        all.frags [length (all.frags)] = new.frags [1]
        all.frags <- c(all.frags, new.frags [2])
      }
      final.text <- paste (all.frags, collapse = "\n")
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      return (final.text)
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    }
}

my_break = function (string, max_length=50) {
  words = unlist(strsplit(string, "[[:space:]]"))
  out = list()
  buf = c()
  i = 1
  for (word in words) {
    if (sum(nchar(buf), length(buf)) + nchar(word) > max_length) {
      out[i] = paste0(buf, collapse=" ")
      i = i + 1
      buf = c(word)
    }
    else {
      buf = c(buf, word)
    }
  }
  
  return(paste0(c(out, paste0(buf, collapse=" ")), collapse="\n"))
}


# The break_text() function nested in wrap_text() returns a vector of two text fragments.
# Those are only returned to the local environment of wrap_text().

#--Try out wrap_text() on a long sentence, with 'wrap.length' set to 30 characters.
my.text <- "This is a really long sentence\tfor a graph title with a lot of pasted things."
wrap_text(my.text, 20)
my_break(my.text, max_length=20)

# Note that a single text string is returned (the '/n's act as carriage returns when the
# text is used in a plot title). None of the fragment pairs from the nested function
# break_text() were returned to the global environment.

# << '...' argument >> -------------------------------------------------------------------

# When you add the argument '...' to a function, that allows you to specify argument
# inputs for nested functions when you call the outer function. To allow the link between
# inner and outer function, you have to add '...' to the call of the inner function as
# well.

# Examine this modification of the graph_traits() function, which we created
# in Part 5. Replace each of two '# ***' with '...', no quotes. This allows links between
# the argument specifications of the outer and inner function.


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
graph_traits <- function (biomes="all", trait.1, trait.2, complete.traits=NULL, # ***) {
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (! "all" %in% biomes) { dat <- glop [glop$biome %in% biomes, ] } else { dat <- glop }
  if (!is.null (complete.traits)) { dat <- dat [complete.cases (dat[complete.traits]), ] }
  if ("all" %in% biomes) {
    title.biomes <- "All" } else {
      title.biomes <- paste (biomes, collapse="; ") }
  title <- paste0 (
    "This is a scatterplot of traits ", trait.1, " vs. ", trait.2, " for biome(s): ",
    title.biomes, ".")
  colnames (dat) [colnames (dat) %in% c(trait.1, trait.2)] = c("trait.1","trait.2")
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #--Wrap title text with wrap_text. Define the first argument and set the rest to '...'
  # to be specified when graph_traits() is called.
  title <- wrap_text (text=title, # ***)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  p <- ggplot (dat, aes(trait.1, trait.2)) + geom_point() + ggtitle (title)
  print (p)
}

#--Call graph_traits() with biomes=c('ALPINE','TEMP_FOR','DESERT','GRASS/M','TROP_FOR'),
# traits 'log.lma', and 'log.ll', and add the argument wrap.length=30.

# ***


#--Do that again, but without specifying wrap.length at all.

# ***

# The default value for 'wrap.length', 60, was used.

#--Alternatively, you can make the optional wrap_text() argument an explicit argument in
# the graph_traits() function. Replace the '...' in the wrap_text() call with
# wrap.length, or wrap.length=wrap.length. Then replace '...' in the graph_traits()
# definition with wrap.length. Give it a default of 40 (overriding wrap_text()'s normal
# default of 60).
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
graph_traits <- function (
  biomes="all", trait.1, trait.2, complete.traits=NULL, # ***) {
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (! "all" %in% biomes) { dat <- glop [glop$biome %in% biomes, ] } else { dat <- glop }
  if (!is.null (complete.traits)) { dat <- dat [complete.cases (dat[complete.traits]), ] }
  if ("all" %in% biomes) {
    title.biomes <- "All" } else {
      title.biomes <- paste (biomes, collapse="; ") }
  title <- paste0 (
    "This is a scatterplot of traits ", trait.1, " vs. ", trait.2, " for biome(s): ",
    title.biomes, ".")
  colnames (dat) [colnames (dat) %in% c(trait.1, trait.2)] = c("trait.1","trait.2")
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #--Replacing the '...' with a reference to the wrap.length argument of graph_traits().
  title <- wrap_text (text=title, # ***)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  p <- ggplot (dat, aes(trait.1, trait.2)) + geom_point() + ggtitle (title)
  print (p)
}

#--Executing graph traits allowing the new default wrap.length=40 to be used.
graph_traits ('all', 'log.lma', 'log.ll')


