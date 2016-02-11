#=========================================================================================
# HW03: Following completion of Part 2 of the R Indexing tutorial
#=========================================================================================

# << INSTRUCTIONS >> ---------------------------------------------------------------------

# You know the drill. Read the questions carefully, and if your code returns an error,
# please take a minute to figure out why, and fix it.

# << DATASETS >> -------------------------------------------------------------------------

# >> Dataset 1:
#--Call in the glopnet.csv dataset into a data frame called 'glop'.
# ***
glop <- read.csv("~/work/ecol596w/data/glopnet.csv")

#--Make the following adjustments to the glop dataframe.
# Fix the column names.
colnames (glop) <- tolower (colnames (glop))
colnames (glop) [ncol(glop)-1] = "ca.ci"
# Make a true 'species' column, calling the existing one 'epithet'.
colnames (glop) [names(glop)=="species"] = "epithet"
glop$species <- paste (glop$genus, glop$epithet, sep="_")
# Back-transform 'log.ll' to a new column 'll' containing leaf lifespan in months.
glop$ll <- 10 ^ glop$log.ll

# >> Dataset 2:
# Here are some Dwarf vectors to play with. These are all the same length and aligned as
# if they were columns in a data frame. E.g., "dopey" is a 142 year old male. But just
# leave them all as separate vectors. I know the seven dwarves are all males, but we'll
# pretend there are some females.
names <- c("dopey", "grumpy", "doc", "happy", "bashful", "sneezy", "sleepy")
ages <- c(142, 240, 232, 333, 132, 134, 127)
sex <- c("m", "m", "f", "f", "f", "m", "m")

# << PROBLEM SETS >> ---------------------------------------------------------------------

# 1) Load the ggplot2 package.
library("ggplot2")

# 2) Use ggplot2 to make a scatter plot of log.ll against log.lma, just for the wetland
# biome "WLAND", colored blue. Replace the *** in this code with the indexed data frame
# and the x and y variable names (no quotes on variable names).
ggplot (data = subset(glop, biome == "WLAND"), aes (log.ll, log.lma)) + geom_point (color="blue")


# 3) Make two different objects, one called 'males', the other called 'females', 
# containing logical vectors indicating TRUE where the dwarves vector 'sex' is equal to
# "m" and "f" respectively. These objects will be used for indexing.
males = sex == "m"
females = sex == "f"

# 4) View 'sex' and view 'males' and make sure the TRUEs and FALSEs in 'males' are
# correctly aligned with the "m" and "f" in 'sex'.
males
females

# 5) View all of the dwarf ages.
ages

# 6) Return the ages of the male dwarves, using the 'males' indexing object.
ages[males]

# Note how you can index inside one object based on tests from another!

# 7) Return the names of the female dwarves (using the 'females' indexing object).
names[females]

# 8) Return the sex of the dwarf named "bashful". Remember, these dwarf vectors are
# aligned as if they're in a data frame, so a given position corresponds to the same dwarf
# in each vector.
sex[names == "bashful"]

# 9) Make a LOGICAL indexing object 'alpine' that will index all the rows containing data
# for the biome "ALPINE" in glop. 'alpine' should be a vector of TRUEs and FALSEs.
alpine <- glop$biome == "ALPINE"

# 10) Make sure the indexing object is working like it should. View the head() of glop,
# with the ALPINE *rows* indexed using your indexing object. You should see only "ALPINE"
# entries in your 'biome' column.
# >> this doesn't work
# glop[alpine]
# Error in `[.data.frame`(glop, alpine) : undefined columns selected

head(glop$biome[alpine])

# 11) What is the longest leaf lifespan in the entire dataset? Use the 'll' column made
# above where the data was called in; that contains leaf lifespan in months. Use the
# function max(), with the added argument na.rm=T, as in: max (x, na.rm=T). That enusres
# max() ignores NAs in the leaf lifespan data.
max(glop$ll, na.rm=T)

# 12) Use the 'alpine' indexing object to ask what the maximum leaf lifespan is in the
# alpine data.
max(glop$ll[alpine], na.rm=T)

# 13) Make 'old' and 'young' objects that are logical vectors indicating dwarf ages older
# and younger-than-or-equal-to 142 respectively.
young <- ages <= 142
old <- ages > 142

# 14) Ask how many dwarves are old OR female (the answer should not be 7; see the second
# sub-part of Indexing: Part 2).
names[old & females]

# 15) What is the ratio of species richness to genus richness (n spp / n gen) in the alpine
# biome? (Break it down: how do you get the number of *different* alpine species?...)
# glop.genus <- unique(subset(glop, biome == "ALPINE", genus))
glop.genus <- unique(glop$genus[alpine])

# glop.species <- unique(subset(glop, biome == "ALPINE", species))
glop.species <- unique(glop$species[alpine])

species.richness <- length(glop.species) / length(glop.genus)
species.richness

# 16) How does that compare to the species/genera ratio for tropical rainforest "TROP_RF"?
rf.ngenus <- length(unique(glop$genus[glop$biome == "TROP_RF"]))
rf.nspecies <- length(unique(glop$species[glop$biome == "TROP_RF"]))
rf.richness <- rf.ngenus / rf.nspecies
rf.richness

# 17) Make a dataframe out of the dwarves vectors. Code already provided.
dwarves <- data.frame (names, ages, sex)

# 18) Using your gender-indexing and age-indexing objects, return the names of the old
# male dwarves from your dwarves data frame.
dwarves$names[old & males]

subset(dwarves, ages > 142 & sex == "m", names)

# 19) Return the unique genus names from the ALPINE biome in glop that have leaves with
# lifespans greater than 10 months ('ll' column, not 'log.ll'). You should see 3 genera.
subset(glop, biome == "ALPINE" & ll > 10, genus)
unique(glop$genus[alpine & glop$ll > 10])

# 20) From your dwarves data frame, return the ages of the dwarf named "grumpy" and all
# the female dwarves. Both conditions should be tested at the same time in the same row
# index of dwarves [,]. You should see four ages returned; check the data frame to make
# sure they're correct.

dwarves$ages[dwarves$names == "grumpy" | females]


# 21) Make this two-color histogram, plotting the histogram of leaf lifespans for the alpine
# and wetland ("WLAND") biomes in separate colors on the same graph for visual comparison.
# Edit this line of code, replacing *** with the glop data frame indexed to return rows
# for BOTH alpine and wetland data (but no other biomes).
ggplot (data = subset(glop, biome=="WLAND" | biome=="ALPINE"), aes (x=ll, fill=biome)) + geom_histogram (position="dodge", binwidth=3)