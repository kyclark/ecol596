#=========================================================================================
# R Class Exercise 5: miscellaneous drills.
#=========================================================================================

# << DIRECTORIES >> ----------------------------------------------------------------------
#--Set two directory paths to the objects below. First is the "Tutorial datasets" folder,
# second is the "Class Exercise 5" folder.
dat.dir = "~/work/ecol596/data"
ce5.dir = "~/work/ecol596/apply-functions"

# << DATASETS >> -------------------------------------------------------------------------
#--Read in "simulated_big_data_131121.csv", "big.tnrs.full.detailed.csv" (in ce5.dir), and
# "glopnet.csv" as data frames, assigning to the objects below.
big = read.csv(file.path(dat.dir, "simulated_big_data_131121.csv"))
big.tnrs = read.csv(file.path(ce5.dir, "big.tnrs.full.detailed.csv"))
glop = read.csv(file.path(dat.dir, "glopnet.csv"))

# << PROBLEM SETS >> ---------------------------------------------------------------------

#--Convert all glopnet column names to lowercase.
colnames(glop) = tolower(colnames(glop))

#--Loop through the columns in 'big' converting factor columns to characters.


#--Do the same for 'glop'.


#--Make a genus column in 'big' by splitting on a "_" separator.
# - First, try out strsplit() on a single species entry.

# - Index the result of strsplit() to retrieve the first element on its own, the genus.

# - Add and fill a genus column in 'big' by looping strsplit() across the species.


#--Use the scrub_taxa() function (in "scrub_taxa.R") to get standardized taxon names for
# 'big' based on results in 'big.tnrs' (from the Taxonomic Name Resolution Service).
# - Source in the scrub_taxa() function in the 'ce5.dir' with source().



# - How do you make R show you the arguments for scrub_taxa()?

# - Try to use scrub taxa to produce a scrubbed version of 'big' with this code:
# scrub_taxa (big, big.tnrs, 'sp', TRUE, indet.nums=TRUE)

# - Why did it fail? Read the error and warnings. Compare the first few species names in
# 'big' with 'submitted.names' in 'big.tnrs'.

# - Replace all underscores in the 'big' species column with " ".

# - Try scrub_taxa() again, replacing 'big' with the output from the function.

# - The warning indicates that some species didn't match up. Which species names in 'big'
# didn't match the 'Name_submitted' column in 'big.tnrs'?

# - How many *different* species names didn't match?

# - How many entries (rows) in 'big' contain those mismatched names?

# - Are there any names in big.tnrs$Name_submitted that don't match big$sp?


#--Using grep() and grepl() for partial matching. Generate indexing objects so we can have
# easy access to custom groups.
# - Use grepl() to make a logical vector for accessing the tropical (i.e not subtropical)
# life zone data. Store to object 'tropical'.

# - Make another one, 'lowland', by life zones that don't contain "montane".

# - How many lowland tropical entries are there in the dataset?

# - With ggplot2, make a boxplot of wood density (wd) values by life zone for lowland
# tropical sites. Use geom_boxplot().


#--grep() and grepl() can only find matches for a single "pattern" in a vector. Write a
# function that acts like a %in% version of grep(), i.e. will return match positions for
# a vector of multiple "patterns". Use grep() inside this function, and allow arguments to
# be passed to grep() from the outer function. (See the last section of the custom
# functions tutorial.)


#--Adding traits to 'big' from 'glop' by taxon matching.
# - How many *different* species match between the two datasets?

# - How many different genera?

# - Can we just use merge() to put data from 'glop' into 'big'? Why or why not?

# - Make a for loop to get species averages of 'log.ll' from 'glop' and transfer them over
# to a new column in 'big' wherever the species matches.

# - Do the same for genus averages. But make sure not to overwrite any species-level data.

# - Put those inside a function that will do that process for any specified data column.

# - Loop the function across all the numeric trait columns in 'glop', filling 'big' with
# all the data we can get.


#--Build a function that creates an 'expanded' version of a dataset, repeating each line a
# number of times specified in a column. For example, 'big' contains one line per species-
# site combination; 'indiv' is the number of trees in that species. Our function should
# expand 'big' to contain one row per tree, replicating each row 'indiv' times. Give it
# two arguments, < data > and < times >, which will be a data frame and a column name
# containing the number of times to replicate each row.






