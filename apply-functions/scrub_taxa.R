#=========================================================================================
# Function for automated integration of TNRS results to a species dataset, and adjustments
# to species names to facilite precision of comparative community analyses.
#=========================================================================================

# << INTRODUCTION >> ---------------------------------------------------------------------

# This function serves to 'scrub' species names for a single dataset, and standardize
# names for comparative work across datasets. 'Scrubbing' involves using the Taxonomic
# Name Resolution Service (TNRS) to fix spellings and resolve synonymies, etc based on
# submitted name matches to taxonomic databases like Tropicos. Standardization for
# comparitive work involves providing unique morpho species tags for each dataset to
# ensure that congeneric indets don't result in artificial species-level matches. Indet
# number additions ensure that congeneric indets don't match each other within a single
# dataset. These additions are optional and customizable.

# << DEVELOPMENT >> ----------------------------------------------------------------------
# Identifying morpho species codes in the dataset:
# - Allow a vector input of morphospecies codes used in the input dataset.
# -- The function should search for those M codes either surrounded by spaces, or followed
# by numbers.
# -- The genus should be recognized by the name preceding the M code, if there is one.
# - Allow 'cf' and 'aff' designations to be optionally assumed to be correct and returned
# as complete species names, or assumed to be unuseful and returned with indet epithets.
# - See what Brad does for pre-scrubbing code.

# << INPUTS >> ---------------------------------------------------------------------------

# - TNRS: R dataframe of the result file from the TNRS output. The TNRS output format
# should be the 'detailed' result from either 'best matches only' or 'all matches'.
# - Data: R dataframe containing the species list to match against the TNRS results. This
# list should ideally be the exact list submitted to TNRS, but the function will merge the
# TNRS results to a partly matching list if provided, but with a warning.

# - TNRS results can be from whole species lists or uniques only.
# - Note that submitting species indets as genus names only, or as genus 'sp' (and
# variations on that), will both work. But in the case of genus-name-only, the
# 'name.submitted' column of the tnrs results will be altered so they receive a 'sp' at
# the end (or other indet tag if specified).

# << OUTPUTS >> --------------------------------------------------------------------------

# - The function outputs a dataframe with scrubbed names and TNRS results merged into the
# original data. The custom column additions to the output data are 'fam.scr', 'gen.scr', 
# 'sp.scr' (scrubbed family, genus, and species names), 'confidence' (stripped "aff" and
# "cf" designations), and 'flag' (custom flags). The scrubbed species names are complete
# binomials, with an indet epithet where not identified to species, or complete
# multinomials if stripping these is not specified.
# - TNRS result columns are also included if specified in the < data.return > argument.
# Optionally, if the TNRS data is of the "all detailed" type, a data frame can be returned
# with the full TNRS data and the columns indicating this function's scoring choice of
# best result for each species; use < data.return > argument "result.choices".
# - Note that the function strips extra blank spaces from submitted names, just as the
# TNRS app does, and therefore direct matches back to the unscrubbed dataset might fail.

# << FUNCTION OUTLINE >> -----------------------------------------------------------------

# - Clean and organize datasets: column name alterations (lowercase and dot separators),
# stripping excess white spaces from submitted names--could result in failure to match
# back to an original dataset.
# - Custom warnings and errors: species name matches between data and tnrs, validity of
# argument inputs.
# - Chooses best of multiple TNRS results: This only done if the TNRS output is 'all
# matches'. Primary difference from TNRS choice is that the presence of detailed opinion
# on a name has top priority, then the database is chosen next in order of priority. See
# definition of < source.priority > argument for more details.
# - Add "sp" to genus-only names.
# - Where tnrs accepted name is blank AND the "name.matched.rank" is "species", use the
# matched name, i.e. the name in the tnrs database that best matched the submitted name.
# - Optional early return of full tnrs with function's scoring and choice of best result
# for each species.
# - Accepted name rank == species: use accepted name.
# - Accepted name rank == genus: use accepted name + epithet of submitted name.
# - Strip extended epithets if specified, resulting in a simple binomial name return for
# each name. See description for < strip.extended.epithets > argument.
# - Deposit 'cf' and 'aff' (i.e. "similar to") designations to separate column to retain
# them. TNRS strips those automatically and returns the binomial, falsely generating
# certainty where there was none.
# - Add scrubbed family and genus names.
# - Add custom flags indicating TNRS "invalid" names and names that had no match to any
# TNRS database. In these cases, the submitted name is returned as the scrubbed name, but
# the flag retains the information that no scrubbing was done.
# - Merge the modified TNRS results with the Data.
# - Indet names and numbers: If specified, append a unique indet identifier specific to
# the submitted dataset. This ensures that congeneric indets don't match between datasets.
# Indet numbers can also be added to ensure congeneric indets don't match within datasets.
# - Return the Data in the specified format, trimming columns according to desired amount
# of information.

# << DEVELOPMENT NOTES >> ----------------------------------------------------------------

# - Only filling in sp.scr based on explicit tests that have to be true, then I can
# avoid providing scrubbed names that didn't match any of my evaluation criteria (i.e.
# situations I hadn't thought of). So don't finish with a "everything else" line.
# - Run this piece by piece on a big dataset like Salvias to see what other features I'm
# not explicitly addressing here.
# - Eventually, would be great to create a wrapper function that calls the internet to
# submit the species list, grab the results, and process them, potentially for multiple
# dataframes in a list, which then all get merged into one.

# << ARGUMENTS >> ------------------------------------------------------------------------

# - All: < dat >  < dat.sp.col >  < tnrs >  < indet.tag >  < indet.nums > < tnrs.type >
# < source.priority >

# < dat > the original dataset.
# - All "sp" epithets will be identified by searching for " sp" at the end of the name,
# or "sp.", or "sp#" with "#" being any number.
# - All "cf" names will be searched by " cf " and "cf."
# - Try to eliminate all weird symbols in the text.
# - The name format in the species column should be "genus epithet".

# < dat.sp.col > The name of the column in 'dat' containing the species list.

# < tnrs > the result from the TNRS output, having given TNRS a list of species names from
# the dataset.

# < indet.tag > (NULL) a character string to append to the end of each unidentified
# species epithet using no separator. This ensures indets don't make direct matches to
# sp.s in the same genus in other datasets (for doing comparative analyses). Appending
# instead of replacing retains morpho distinctions within a dataset.

# < indet.tag.method > ("replace") ["append"] How to handle the indet.tag additions,
# whether to replace the existing indet epithet (e.g., "sp") with the indet.tag, or append
# the tag to the existing epithet. This argument is only active if < indet.tag > is not
# NULL.

# < indet.nums > Logical; Should numbers be added to each indet epithet so indets don't 
# match each other in this dataset? Numbers follow a '.' separator. This is only not a
# good idea when morpho species have been carefully determined in the dataset and can
# therefore be treated as good names for matching and differentiating species in the
# dataset.

# < strip.extended.epithets > (TRUE) Logical. Whether to strip variety and subspecies
# eptithets, as well as 'x' in nothospecies like "Musa x paradisiaca".

# < data.return > ('simple') ['partial.tnrs', 'full.tnrs', 'result.choices'] For the first
# three options, the data returned is always the original dataset with scrubbed names
# merged in. These options determine how much information (columns) from the TNRS results
# to also include. 'simple' appends only the scrubbed fam/gen/sp names and the 
# 'confidence' column to the returned data. 'partial.tnrs' adds 'accepted.name.rank', 
# 'taxonomic.status', 'name.matched.rank', and 'name.score'. 'full.tnrs' includes every 
# column, but if < tnrs.type > == "all", then this is filtered to "custom best" result 
# choices, i.e. only one row per submitted name. 'result.choices' is only useful when  
# < tnrs.type > == "all". This returns the full, detailed tnrs output with the columns 
# showing custom match scores and the custom "best result" choices. This is for manual
# evaluation of the function's match choices. The original dataset is not merged in this
# return.

# < tnrs.type > ("all") ["best"] TNRS output type. All outputs used should be 'detailed',
# but can either go with 'best' or 'all' matches. Using 'all' allows for prioritization of
# database source. Not prioritizing source can result in matches to 'accepted names' from 
# different datasets for the same species with differing spelling. For example, Tropicos 
# treats Mezilaurus itauba as accepted, but if 'Mezilaurus ita-uba' is input, it will 
# match a different database that accepts 'ita-uba'. Because it has a perfect match to 
# that database, it will be prioritized over Tropicos's result.

# < source.priority > ("default") A character vector defining the order of prioritization
# of source databases for name matches. Not all possible sources need to be supplied. If
# priority sources aren't matched, the remaining sources will be prioritized
# alphabetically.
# - This defeats tnrs's automated selection of the 'best' match. Therefore, other choices
# need to be made to prioritize good name matches before picking the source. The code
# isolates the names with the most information, then prioritizes by database, then by
# tnrs's 'overall [match] score', then prioritizes 'accepted' taxonomic statuses (favors
# maintenance of the original name over suspect synonyms in ambiguous database matches),
# then takes the first of any remaining ties.
# - TNRS has other options for match choice. Best matches can be constrained by higher
# taxonomy (potentially useful) or database source. However, when prioritizing source, the
# source priority comes first, whereas is this function, a first round of elimination is
# done based on amount of provided information (quantity of opinion). Therefore, whereas
# if 'tropicos' were top priority with TNRS's prioritization, a tropicos result with no
# opinion would be selected over another result with an opinion. This function would
# reject the tropicos result and take the next priority source with an opinion. After
# that round, the TNRS and this function filter similarly, by spelling match and then
# alphabetically.

# << FUNCTION >> -------------------------------------------------------------------------
scrub_taxa <- function (
  dat, tnrs, dat.sp.col, indet.tag=NULL, indet.tag.method="replace", indet.nums=FALSE, 
  strip.extended.epithets=TRUE, data.return="simple", tnrs.type="all", 
  source.priority="default") {

  # << Clean and organize the datasets >> ------------------------------------------------

  #--Convert all tnrs column names to lowercase.
  colnames (tnrs) = tolower (colnames (tnrs))
  #--Convert all "_" in tnrs colnames to ".".
  colnames (tnrs) = gsub ("_", ".", colnames(tnrs))
  #--Convert all factor columns to class character.
  for (c in 1:ncol(tnrs)) {
    if (is.factor (tnrs[[c]])) { tnrs[[c]] <- as.character (tnrs[[c]]) } }
  for (c in 1:ncol(dat)) {
    if (is.factor (dat[[c]])) { dat[[c]] <- as.character (dat[[c]]) } }

  # << Clean data >> ---------------------------------------------------------------------
  # Strip extra white spaces from the original data names and the tnrs submitted names,
  # since these might differ after submitted names are exported from tnrs and cause
  # mismatches and uniques that are not actually unique.
  strip_extra_blanks <- function (x) {
    separated <- strsplit (x, " ")[[1]]
    separated <- separated [!separated==""]
    blanks.stripped <- paste (separated, collapse=" ")
    return (blanks.stripped)
  }
  dat[[dat.sp.col]] <- sapply (dat[[dat.sp.col]], FUN=strip_extra_blanks)
  tnrs$name.submitted <- sapply (tnrs$name.submitted, FUN=strip_extra_blanks)
  
  #--Identify non-blanks and non-nas in both datasets, seeking nas in a variety of ways.
  dat.non.blanks <- which (
    !is.na (dat[[dat.sp.col]]) & dat[[dat.sp.col]] != "" &!
      grepl ("^[Nn][Aa]$", dat[[dat.sp.col]]) &! grepl ("^[Nn]/[Aa]$", dat[[dat.sp.col]]))
  tnrs.non.blanks <- which (
    !is.na (tnrs$name.submitted) & tnrs$name.submitted != "" &! 
      grepl ("^[Nn][Aa]$", tnrs$name.submitted) &!
      grepl ("^[Nn]/[Aa]$",tnrs$name.submitted))
  #--Trim the tnrs to 'non.blanks'.
  tnrs <- tnrs [tnrs.non.blanks, ]
  
  # << Custom warnings and errors >> -----------------------------------------------------
  
  #--Test whether all species names in the dataset are present in the tnrs submitted
  # names, and vice versa.
  if (!all (dat[[dat.sp.col]][dat.non.blanks] %in% tnrs$name.submitted)) { warning (
    "Not all dataset species names occur as submitted names in tnrs. Only matching names
    will be evaluated. Check that 'gen sp sub.sp' separator in dataset is a space. If not,
    use gsub() to change.") }
  if (!all (tnrs$name.submitted %in% dat[[dat.sp.col]][dat.non.blanks])) { warning (
    "Not all submitted names in tnrs occur in dataset 'dat.sp.col' column. Only matching
names will be evaluated. Check that 'gen sp sub.sp' separator in dataset is a space. 
If not, use gsub() to change.")}
  
  #--Return an error if none of the species names in the datset are present in the tnrs
  # submitted names. This satisfies the reverse test as well.
  if (!any (dat[[dat.sp.col]] %in% tnrs$name.submitted)) {
    stop ("No species name matches between dataset and tnrs submitted names.") }
  
  #--Return an error if there are column names in the data that match column names in the
  # specified tnrs return.
  simple.return.cols = c('fam.scr','gen.scr','sp.scr','confidence','flag')
  partial.return.cols = c('name.matched.rank', 'name.score', 'accepted.name.rank',
                          'taxonomic.status', 'fam.scr', 'gen.scr', 'sp.scr',
                          'confidence', 'flag')
  full.return.cols = c(simple.return.cols, names(tnrs))
  if (data.return=="simple" & any (names (dat) %in% simple.return.cols)) {
    col.matches = names (dat) [names (dat) %in% simple.return.cols]
    stop (paste0 ("The following column names in submitted data match tnrs names in the",
                  "simple return format: ", paste (col.matches, collapse=", "), ". ",
                  "Make matched column names unique before running function.")) }
  if (data.return=="partial.tnrs" & any (names (dat) %in% partial.return.cols)) {
    col.matches = names (dat) [names (dat) %in% partial.return.cols]
    stop (paste0 ("The following column names in submitted data match tnrs names in the",
                  "partial.tnrs return format: ", paste (col.matches, collapse=", "),". ",
                  "Make matched column names unique before running function.")) }
  if (data.return=="full.tnrs" & any (names (dat) %in% full.return.cols)) {
    col.matches = names (dat) [names (dat) %in% full.return.cols]
    stop (paste0 ("The following column names in submitted data match tnrs names in the",
                  "full.tnrs return format: ", paste (col.matches, collapse=", "), ". ",
                  "Make matched column names unique before running function.")) }
  
  #--Errors for invalid arguments where argument options are fixed.
  if (! indet.tag.method %in% c("replace","append")) {
    stop (paste0 ("'", indet.tag.method, "' is not a valid indet.tag.method input.")) }
  if (! data.return %in% c('simple','partial.tnrs', 'full.tnrs', 'result.choices')) {
    stop (paste0 ("'", data.return, "' is not a valid data.return input.")) }
  if (! tnrs.type %in% c("all","best")) {
    stop (paste0 ("'", tnrs.type, "' is not a valid tnrs.type input.")) }
  available.sources = do.call ('c', sapply (tnrs$source, function(x)strsplit(x,";")))
  available.sources = unique (available.sources)
  if (source.priority != "default" & ! all (source.priority %in% available.sources)) {
    warning (paste0 ("Sources provided in source.priority argument do not all match ",
                     "available sources in tnrs data.")) }
  
  # << Choosing best tnrs results >> -----------------------------------------------------
  
  # If the TNRS output used is the 'all detailed' type, run through a hierarchy of
  # eliminations to choose the best result, including by prioritization of data source.
  
  # Hierarchical elimination procedure:
  # - First, assign a ‘custom match score’, which adds discount points for lacking
  # accepted names, etc.
  # - Then, among the best (lowest) custom match score ties, pick the priority database.
  # - Among ties there, pick the highest tnrs ‘overall score’.
  # - Among ties there, choose any ‘taxonomic status’ equal to 'accepted'. (Resolves 
  # ambiguous matches, favoring preservation of the original name over suspect synonym
  # changes.)
  # - If there’s still a tie, take the first in order.
  
  if (tnrs.type=="all") {
    
    #--Assign a custom match score to each row. 1 point for lacking an accepted name.
    # 1 point for an accepted name rank different from species.
    tnrs$custom.match.score = 0
    tnrs [tnrs$accepted.name=="", "custom.match.score"] = 1
    tmp.index <- which (tnrs$accepted.name.rank != "species")
    tnrs [tmp.index, "custom.match.score"] = tnrs [tmp.index, "custom.match.score"] + 1
    
    #--Set up the source priority vector.
    # Make a vector of available sources.
    all.sources <- sapply (unique (tnrs$source), function (x) strsplit (x, ";"))
    all.sources <- unique (do.call ('c', all.sources))
    # Make a vector of sources in order of priority. Specified source priorities come
    # first, then any other available sources come in alphabetical order.
    if (source.priority=="default") { source.priority = c("tropicos", "usda") }
    all.sources <- all.sources [! all.sources %in% source.priority]
    source.priority = c(source.priority, all.sources [order (all.sources)])
    
    #--Assign a source priority score.
    score_source <- function (row) {
      if (tnrs [row, "source"] != "") {
        sources <- strsplit (tnrs [row, "source"], ";") [[1]]
        score <- min (sapply (sources, function (s) grep (s, source.priority))) 
      } else { score = 0 }
    }
    tnrs$source.score <- sapply (1:nrow(tnrs), FUN=score_source)
    
    #--Function for choosing the 'best' tnrs result for a given species. Function returns
    # the row index of the 'best' result in tnrs.
    get_best_result_rows <- function (sp) {
      sp.rows <- which (tnrs$name.submitted==sp)
      #--Isolate rows with the best custom.match.score.
      round1 <- which (
        tnrs [sp.rows, "custom.match.score"] == min (tnrs [sp.rows,"custom.match.score"]))
      sp.rows <- sp.rows [round1]
      #--Isolate rows with the best source.score.
      round2 <- which (
        tnrs [sp.rows, "source.score"] == min (tnrs [sp.rows, "source.score"]))
      sp.rows <- sp.rows [round2]
      #--Isolate rows to the highest tnrs 'overall.score'.
      round3 <- which (
        tnrs [sp.rows, "overall.score"] == max (tnrs [sp.rows, "overall.score"]))
      sp.rows <- sp.rows [round3]
      #--Isolate to 'accepted' 'taxonomic.status' if there are any.
      if (any (tnrs [sp.rows, "taxonomic.status"] == "Accepted")) {
        round4 <- which (tnrs [sp.rows, "taxonomic.status"] == "Accepted")
        sp.rows <- sp.rows [round4] }
      #--Pick the first row number in the remaining collection.
      best.row <- sp.rows [1]
      #--Return the best row.
      return (best.row)
    }
    
    #--Get a vector of all the best result rows.
    best.rows <- sapply (unique (tnrs$name.submitted), FUN=get_best_result_rows)
    
    #--Designate the best tnrs result rows in a 'custom.best' column.
    tnrs$custom.best <- ""
    tnrs$custom.best [best.rows] = "best"
    
    #--If the < data.return > argument specifies 'result.choices', return this tnrs data
    # frame without further modification or merging with the original dataset.
    if (data.return == "result.choices") { return (tnrs) }
    
    #--Trim the tnrs to the custom 'best' results only.
    tnrs <- tnrs [tnrs$custom.best=="best", ]
    
  } # END IF: tnrs.type=='all'
  
  # << Make the working dataframe >> -----------------------------------------------------

  #--Identify genus-only names, and add 'sp'. Necessary for downstream work.
  add_sp <- function (sp) {
    sp.split <- strsplit (sp, " ")[[1]]
    if (length (sp.split) == 1) { return (paste (sp.split, "sp")) 
    } else { return (sp) }
  }
  dat[[dat.sp.col]][dat.non.blanks] <- sapply (
    dat[[dat.sp.col]][dat.non.blanks], FUN=add_sp)
  tnrs$name.submitted <- sapply (tnrs$name.submitted, FUN=add_sp)
  
  #--Simplify the tnrs dataset to unique submitted names to avoid merging errors.
  names <- tnrs [!duplicated (tnrs$name.submitted), ]
  
  #--Make a data frame 'names' defined by the intersection of the dataset species names
  # and the tnrs submitted names.
  # [DEV] I'm eliminating the merge part here. I should merge at the end so I can work
  # with a complete dataset.
  # names <- merge (dat, tnrs, by.x=dat.sp.col, by.y="name.submitted", all=F)
  # colnames (names) [colnames (names) == dat.sp.col] = "name.submitted"

  #--Add accepted name columns for family, genus, and species. These will be gradually
  # filled and edited, and then deposited back into the original dataset to be returned.
  names [c("fam.scr","gen.scr","sp.scr")] = ""

  # << No accepted name >> ---------------------------------------------------------------

  #--Where tnrs accepted name is blank AND the "name.matched.rank" is "species", use the
  # matched name, i.e. the name in the tnrs database that best matched the submitted name.
  # These are often cases with no opinion on the accepted name, or the name might be
  # invalid. The only improvement that can be made is to standardize to the name matched
  # in the tnrs database.
  tmp.index <- which (names$accepted.name=="" & names$name.matched.rank=="species")
  names [tmp.index, "sp.scr"] = names [tmp.index, "name.matched"]
  #--Where tnrs accepted name is blank AND the 'name.matched.rank' is "genus", use the
  # matched genus name, pasted to everything following the genus name in the submitted
  # name. E.g., "Pterocarps sp.1" matches "Pterocarpus" and becomes "Pterocarpus sp.1".
  tmp.index <- which (names$accepted.name=="" & names$name.matched.rank=="genus")
  tmp.epithets <- sapply (names$name.submitted [tmp.index], function (x) {
    paste (strsplit (x, " ") [[1]][-1], collapse=" ") })
  names [tmp.index, "sp.scr"] = paste (names [tmp.index, "name.matched"], tmp.epithets)
  #--Where the 'overall.score' is 0, use the submitted name (no match in the database).
  tmp.index <- which (names$overall.score == 0)
  names [tmp.index, "sp.scr"] = names [tmp.index, "name.submitted"]

  # << Accepted names ranked genus and species >> ----------------------------------------
  
  # These are non-blank 'accepted.name' entries where 'accepted.name.rank' equals 'genus'
  # or 'species'.

  #--Accepted name rank == species: use accepted name.
  tmp.index <- which (names$accepted.name.rank == "species")
  names [tmp.index, "sp.scr"] = names [tmp.index, "accepted.name"]
  #--Accepted name rank == genus: use accepted name + epithet of submitted name.
  tmp.index <- which (names$accepted.name.rank == "genus")
  tmp.epithets <- sapply (names$name.submitted [tmp.index], function (x) {
    paste (strsplit (x, " ") [[1]][-1], collapse=" ") })
  names [tmp.index, "sp.scr"] = paste (names [tmp.index, "accepted.name"], tmp.epithets)

  # << Other accepted name ranks >> ------------------------------------------------------
  # E.g., variety, subspecies, nothospecies.

  #--Index object for accepted names with extended epithets, i.e. where accepted.name.rank
  # is variety, subspecies, nothospecies, or cv ('cultivar'?).
  ext.eps <- which(names$accepted.name.rank %in% c("variety","subspecies","nothospecies"))

  #--Refer to 'strip.extended.epithets' argument to determine whether to turn extended
  # epithets into simple binomials for ease of use, or take the accepted name as is.
  if (strip.extended.epithets) {
    #--Index objects for varieties, subspecies, and nothospecies.
    vars <- which (names$accepted.name.rank == "variety")
    nothos <- which (names$accepted.name.rank == "nothospecies")
    subsp <- which (names$accepted.name.rank == "subspecies")
    cv <- which (names$accepted.name.rank == "cv")
    #--Strip epithet extensions vars and subs and 'x' for nothos. Vars are always "Gen sp
    # var. var.x" so just keep first two components. Nothos are "Gen x sp", so eliminate
    # "x ". Subspecies are "gen sp subsp. subsp", so just keep first two components.
    if (length (vars) > 0) {
      names [vars, "sp.scr"] = sapply (names [vars, "accepted.name"], function (x)
        paste (strsplit (x, " ") [[1]] [1:2], collapse=" ")) }
    if (length (nothos) > 0) {
      names [nothos, "sp.scr"] = gsub ("x ", "", names[nothos,"accepted.name"]) }
    if (length (subsp) > 0) {
      names [subsp, "sp.scr"] = sapply (names [subsp, "accepted.name"], function (x)
      paste (strsplit (x, " ") [[1]] [1:2], collapse=" ")) }
    # DEV NOTE: The 'cv' added later when discovered. Realized "accepted.name.species"
    # already provides a single binomial. This may work for the others above as well.
    if (length (cv) > 0) {
      names [cv, "sp.scr"] = names [cv, "accepted.name.species"] }
  } else { names [ext.eps, "sp.scr"] = names [ext.eps, "accepted.name"] }

  # << cf, and affinity names >> ---------------------------------------------------------
  # "cf" and "aff" are often inserted between genus and epithet, meaning "looks like".
  # The TNRS automatically ignores these and correctly matches the suggested species name.
  # This section just adds the 'cf' or 'aff' label to a 'confidence' column to retain the
  # indication of uncertainty.
  names$confidence <- ""
  cf.rows <- c(
    grep (" cf ", names$name.submitted), grep ("cf.", names$name.submitted, fixed=T))
  if (length (cf.rows) > 1) { names$confidence [cf.rows] = "cf" }
  aff.rows <- c(
    grep (" aff ", names$name.submitted), grep ("aff.", names$name.submitted, fixed=T))
  if (length (aff.rows) > 1) { names$confidence [aff.rows] = "affinis" }
 
  # << Family and genus names >> ---------------------------------------------------------
  
  #--Take the TNRS suggested family wherever there is one.
  names$fam.scr <- names$accepted.name.family
  #--Where there is no TNRS accepted family, take the name.matched.accepted.family. These
  # are cases where the 'taxonomic.status' is 'invalid', 'illegitimate', or 'no opinion'.
  blank.fams <- which (names$accepted.name.family == "")
  names$fam.scr [blank.fams] = names$name.matched.accepted.family [blank.fams]
  
  #--Get the genus from the scrubbed species names.
  names$gen.scr <- sapply (names$sp.scr, function (x) strsplit (x, " ")[[1]][1])
  
  # << Flags >> --------------------------------------------------------------------------
  
  #--Blank accepted.name.rank should be turned to "none", for clarity.
  tmp.index <- which (names$accepted.name.rank == "")
  names$accepted.name.rank [tmp.index] = "none"
  #--Make a 'flag' column to add useful flags for interpretation of scrubbed results.
  names$flag <- ""
  # Invalid names are critical to know. These are often genus misspellings that will
  # produce no accepted name. This function will take the submitted name, thus creating a
  # new unique genus that shouldn't exist.
  invalids <- which (names$taxonomic.status=="invalid")
  names$flag [invalids] = "invalid name"
  # When no suitable matches are found, no family will be provided, and the name should be
  # suspect.
  no.match <- which (names$name.matched=="No suitable matches found.")
  names$flag [no.match] = "No name match in TNRS database"
  
  # << Merge >> --------------------------------------------------------------------------
  
  #--Merge the names and original dataset.
  names <- merge (dat, names, by.x=dat.sp.col, by.y="name.submitted", all.x=T)
  
  # << Indet names and numbers >> --------------------------------------------------------
  
  # This section identifies unidentified species, aka 'indets', adds unique indet tags if
  # specified (so as not to match indets in other datasets), and adds unique numbers to
  # each indet so indets don't match each other. This essentially creates unique morpho
  # IDs for indets. If unique morphos have been determined in a dataset already,
  # indet.nums arg should be FALSE so as not to override intra-dataset matches.
  # [DEV] Currently, the code searches for versions of 'sp' for indets. I could add an
  # argument that is a vector of morpho tags to match for identifying indets to be
  # flexible for other indet codes, like "indet.", or "morpho".
  
  #--Search criteria for "sp" epithets: 1) " sp$" will find " sp" at the end of a name.
  # 2) "sp[0-9]" will find "sp#" for any sp number. 3) For "sp.", use fixed=T argument of
  # grep to override the '.' metacharacter.
  indets <- c(
    grep (" sp$", names$sp.scr), grep ("sp[0-9]", names$sp.scr),
    grep ("sp.", names$sp.scr, fixed=T) )
  
  #--Add the indet tags and numbers.
  if (length (indets) > 0) {
    # Add indet tags if specified.
    if (!is.null (indet.tag)) {
      if (indet.tag.method=="replace") {
        indet.genera <- sapply (names$sp.scr [indets], function(x)strsplit(x," ")[[1]][1])
        names$sp.scr [indets] = paste (indet.genera, indet.tag) }
      if (indet.tag.method=="append") {
        names$sp.scr [indets] <- paste0 (names$sp.scr [indets], indet.tag) }
    }
    # If specified by indet.nums arg (T/F), add unique numbers to all indet epithets.
    if (indet.nums) {
      names$sp.scr [indets] <- paste0 (names$sp.scr [indets], ".", 1:length(indets)) }
  }
  
  # << Return >> -------------------------------------------------------------------------
  
  #--Vectors of column names for alternative data returns.
  original.cols <- names(dat)
  simple <- c(original.cols, 'fam.scr','gen.scr','sp.scr','confidence','flag')
  partial <- c(original.cols, 'name.matched.rank', 'name.score', 'accepted.name.rank',
               'taxonomic.status', 'fam.scr', 'gen.scr', 'sp.scr', 'confidence', 'flag')
  
  #--Data return.
  if (data.return == "simple") { return (names [simple]) }
  if (data.return == "partial.tnrs") { return (names [partial]) }
  if (data.return == "full.tnrs") { return (names) }
}


# << TESTING AND DEBUGGING >> ------------------------------------------------------------

# - Checked that unmatched species between dat and tnrs result in NA .scr columns.
# - Checked through a lot of my custom best tnrs result choices and I think they are good.
# - Tested whether a re-scrub resulted in the same accepted name results as an initial
# scrub, which it did.
# - *Have not tested returns of nothospecies, subspecies, and vars yet to see whether
# trinomials mess anything up.

# << TEMPORARY FOR DEVELOPMENT >> --------------------------------------------------------
# dat.dir <- "/Users/ttaylor/Documents/Academic/Resources/R/Ty's functions/Development datasets/"

# << TEMPORARY ARGUMENTS >>
# dat <- read.csv (paste0 (dat.dir, "Isoprene survey_FuncDev.csv"))
# dat.sp.col = "species.given"
# dat[dat.sp.col] = gsub ("_"," ",dat[[dat.sp.col]])
# tnrs <- read.csv (paste0 (dat.dir, "Isoprene survey_tnrs res_all detailed_FuncDev.csv"))
# tnrs2 <- read.csv (paste0 (dat.dir, "rescrub test_tnrs res_all detailed.csv"))
# dat.sp.col = "species.given"
# strip.extended.epithets=TRUE
# indet.tag = "iso"
# indet.nums = TRUE
# data.return="simple"
# tnrs.type="all"
# source.priority="default"
# # 

# << TESTS >> ----------------------------------------------------------------------------

# dat2 <- scrub_species_names (
#   dat, tnrs, "species.given", indet.tag="sp.iso", indet.tag.method="replace", 
#   indet.nums=TRUE, strip.extended.epithets=TRUE, data.return="simple")
# write.csv (dat2, paste0 (dat.dir, "simple_test.csv"), row.names=F)
# 
# dat3 <- scrub_species_names (
#   dat, tnrs, "species.given", indet.tag="iso", indet.nums=TRUE, 
#   strip.extended.epithets=TRUE, data.return="partial.tnrs")
# write.csv (dat3, paste0 (dat.dir, "partial_test.csv"), row.names=F)
# 
# dat4 <- scrub_species_names (
#   dat, tnrs, "species.given", indet.tag=NULL, indet.nums=FALSE, 
#   strip.extended.epithets=TRUE, data.return="full.tnrs")
# write.csv (dat4, paste0 (dat.dir, "full_test.csv"), row.names=F)
# 
# #--Take original scrub of the isocomm dataset and compare the non-blank 'accepted.name'
# # results when filtered to my custom.best, and compare to accepted custom best names from
# # the scrub of that set. Determines circular consistency. 
# dat4 <- dat4 [dat4$accepted.name != "", ]
# tnrs.rescrub <- scrub_species_names (
#   dat, tnrs2, "species.given", indet.tag=NULL, indet.nums=FALSE, 
#   strip.extended.epithets=TRUE, data.return="result.choices")
# tnrs.rescrub.best <- tnrs.rescrub [tnrs.rescrub$custom.best=="best",]
# 
# mismatch = which (tnrs.rescrub.best$accepted.name != tnrs.rescrub.best$name.submitted)
# tnrs.rescrub.best [mismatch, ]
# 
# write.csv (tnrs.rescrub, paste0 (dat.dir, "tnrs.rescrub.csv"), row.names=F)
