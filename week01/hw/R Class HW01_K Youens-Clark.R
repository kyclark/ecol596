#=========================================================================================
# R Class 2016, HW01: Review of Tutorial 1, first session.
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

# 1) What is the lower left window in R Studio called?

# >> Console

# 2) How do you execute a whole line of code from the script window?

# >> On my Mac, Command-Enter when the cursor is on the line

# 3) How do you execute part of a line, or multiple lines of code from the script window?

# >> Highlight the region, press Command-Enter

# 4) How does R see the following two entries differently when you execute them?
"x" # >> This is the literal character "x"
x # >> This is an unknown object called "x"


# 5) Make an object named 'v1' equal to a vector of the numbers 1,5,10,11,12,13.

v1 <- c(1,5,10,11,12,13)

# 6) Check what 'class' of object 'v1' is (using code).

class(v1)

# 7) What does "indexing" mean? (just briefly, generally)

# >> Indicating part of a vector/matrix/data.frame 

# 8) Ask R to show you the fifth element of 'v1'.

v1[5]

# 9) Ask R to show you the third element of 'v1' multiplied by 2.

v1[3] * 2

# 10) Divide 8 by the product of 4 and 2. Does R recognize the order of operations PEMDAS,
# or do you need parentheses? Try both ways.

8 / (4 * 2) # == 1

8 / 4 * 2 # == 4, groups (8/4) * 2, so parens are needed




