#=========================================================================================
# R Tutorial 1 drill set, by Ty Taylor (tytaylor@email.arizona.edu)
#=========================================================================================

# << INFORMATION >>
# Practice, practice, practice! Here are some drills to accompany Section 1.
# Use the BLANK script to answer as best you can, and refer to the completed script for
# completed answers. Remember that there are often many ways to do the same thing in R!
# Just reading through the completed script would also be beneficial.

# If something is unfamiliar, try using 'Find' in RStudio to search through the tutorial
# sript for an example or explanation.

# If the whole thing is too unfamiliar, just practice typing in the code as you see it in
# the completed script, trying to understand the syntax as you go. Then try going through
# it again on your own.

# To see the arguments required for a function, execute ?function_name, e.g.,
?matrix

# << CONTENTS >>
# >> Basic objects, math, vectors, matrices, basic functions
# >> Data frames

#-----------------------------------------------------------------------------------------
# Basic objects, math, vectors, matrices, basic functions
#-----------------------------------------------------------------------------------------

#--Make an object named 'fred' equal to 6 raised to the 5th power. Then view 'fred'.


# Divide 'fred' by 6^4.



#--Divide 8 by the product of 4 and 2. Does R recognize the order of operations PEMDAS, or
# do you need parentheses? Try both ways.




#--Make an object equal to a vector of the numbers 7,9,15,16,17,18,19,20 using the ':'
#shortcut for numbers in series. Name the object whatever you want.


# Ask R how many elements are in your object just created (in R language, what is its
# 'length'?).


# Ask R what class your object is.



#--Use the rep() function to make an object 'x' equal to the word "repetition" repeated
# four times. (Review the << R Help >> section of the tutorial to see how to use rep() ).
# - What is 'x' (view it)?
# - What class are its elements?
# - Do you need the c() function to create this object? Does it make a difference?







#--Make an object a numerical vector of length 20. Use some number repetition and also
# number series by nesting the rep() function and the ':' operator into the definition of
# the vector. Use any set of numbers you like.


# Now convert your vector object into a matrix named 'mat1' with 4 columns.


# Ask R to show you the 18th element in your matrix (one-dimensional indexing).


# Ask R to show you the element in the 4th row and 2nd column using two-dimentsional
# indexing.


# Ask R to show you the entire 2nd column.


# Make a new matrix, 'mat2', equal to just the 2nd and 3rd columns of 'mat1'. View 'mat2'.



# Make the first element in the second column of mat2 equal to the word "three".
# View mat 2.



# What happened? Why did that happen?
# >> A matrix, like a vector, can only contain elements of like 'class'. You introduced
# a character string, so R converted all the numbers to characters.


#--Nest the rnorm() function inside of the matrix() function to create a matrix called
# 'n.mat' with 80 elements drawn from a normal distribution with mean=10 and sd=3. Give
# the matrix 8 rows. Name all of the arguments in rnorm() when you call them.



# Repeat the above, without naming the rnorm arguments (type it out for muscle memory).



#--Create a vector with the rep() function nested in the c() function, starting with five
# zeros in a row, followed by 1,2.



#--Make a matrix named 'words' with two columns and three rows.
# - Make the first column contain the word "one" in each row.
# - Make the second column contain the words "two", "three", "four".
# - Build this matrix with one line of code, by nesting the rep() (for "one") and c() (for
# "two", "three", "four") functions inside of c() in the first argument of matrix().
# *Keep track of your parentheses and commas! You must get out of the closing parentheses
# of an inner function before placing the comma to start the next argument of its outer
# function. Use spaces strategically to make it easier to see the separations of inner and
# outer functions.



# Now make a vector named 'one_two' equal to the result of pasting column 1 of 'words'
# with column 2 of 'words'. Make the separator of paste() an underscore "_".




#--Make a numerical matrix of length 20 with two columns. Give it any name.


# Get the mean() of all the data in your matrix.


# Get the standard deviation sd() of the first 6 entries in the 2nd column of your matrix.


# Return the minimum min() value from the set of items 1,4, and 6 through 10 in the first
# column.


# Return the maximum value from items 5,6, and 9 in the second column.


# View the product of the whole second column multiplied by 2.


# Make items 2 and 4 in the first column equal to items 6 and 7 in the second column
# multiplied by 2. View your matrix to make sure it changed the way you expected.


# Make the entire second column equal to the entire first column divided by 10. View the
# altered matrix.


# Ask R what the class() of your matrix is.


# Ask R what the class() of the second column of your matrix is.


# Make a new matrix that is equal to the top half your previous matrix.




#-----------------------------------------------------------------------------------------
# Data frames
#-----------------------------------------------------------------------------------------

# >> NOT COMPLETED YET.


