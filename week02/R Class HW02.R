#=========================================================================================
# HW02: Following completion of Section 1 tutorial 'R_Primer'
#=========================================================================================

# << INSTRUCTIONS >> ---------------------------------------------------------------------
# - Have this script open in R Studio in a tab alongside the relevant tutorial scripts.
# - Re-name this script, adding to the existing filename an underscore and your first
# initial and last name, e.g., "R Class HW01_T Taylor.R".
# - If the question calls for a verbal (plain English) answer, answer as a 'comment' (i.e.
# put a # at the start of each line.) Please also start the first line of your answer with
# "# >> ". (That helps me scan through and identify answers quickly.)
# - If the question calls for code, just type in the code below the question. I want to
# see your code, not what R produces from your code.
# - Upload your completed homework R script to your homework Dropbox folder.

# Examples:
# E1) What is the upper left window pane in R Studio called?
# >> The script window (or 'source').

# E2) Ask R to show the answer to two plus two.
2 + 2

# << QUESTIONS >> ------------------------------------------------------------------------

# 1) Finish the 'R_Primer' tutorial on your own. In class, we ended before the third
# section of Part 8, "Using custom directories...". You do not need to submit anything for
# this problem.

# 2) Call the glopnet.csv file into a data frame called 'glop'. Use any method you like,
# but show your code. You may replace your actual directory chain with 'my directory' if
# you don't want to share your actual directory path with me (i.e. share all of your
# personal folder names, etc.).


# 3) Return the number of rows in 'glop'.


# 4) Return the number of columns in 'glop'.


# 5) Return the names of columns 4 through 10 in 'glop'.


# 6) Show me three different ways to index the 'Genus' column and return the first 5
# entries in that column.


# 7) Change the name of the 5th column to "Epithet".


# 8) Make a new column named "Species" that is equal to the 'Genus' column pasted with the
# 'Epithet' column with an underscore "_" separator.


# 9) Take a look at the head() of 'glop' to make sure 'Species' looks like it should.


# 10) Return the number of unique species names in 'glop'.


# 11) Use code to determine whether all the species names are unique or not. (Doesn't need
# to be a coded logical test that returns TRUE/FALSE. Just show me a way that you would
# check for your own knowledge.)


# 12) Install AND load into R the package 'ggplot2'.


# 13) Make a scatter plot with any two numerical columns of interest on the x and y axes.
# - "LL" = leaf life span; "LMA" = leaf mass per area; "Nmass" and "Narea" are mass and
# area based nitrogen content; "Gs" = stomatal conductance; ...
# - Use the following code, replacing 'x' and 'y' with your UNQUOTED column names. (This
# is just a ggplot preview to start getting used to it.)
# ggplot (data = glop, aes (x, y)) + geom_point()


# 14) Try the same plotting code, except add an argument inside aes(): color=BIOME


# 15) Make a histogram of any numerical column of choice from 'glop'. The syntax is
# similar to the above, just with one variable in aes() instead of two, and the geometry
# is geom_bar().



