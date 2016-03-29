#========================================================================================#
# Function for wrapping text in plot titles, etc., by inserting '\n' where specified
#========================================================================================#

# << INFORMATION >> ----------------------------------------------------------------------

# Name: wrap_text
# Function will take a text string and a specified maximum character length. It will
# return the text string with \n (carriage return) inserted at the nearest space prior to
# the n-character line length specification.

# The primary purpose is to provide an easy way to automate the wrapping of titles in
# figures.

# << ARGUMENTS >> < argument > (default) Description. ------------------------------------

# < text > () your character string to wrap.
# < wrap.length > (60) maximum number of characters per line (defining where to wrap).

# << FUNCTION >> -------------------------------------------------------------------------

wrap_text <- function (text, wrap.length=60) {
  #--Look at character wrap.length+1. If it is a space, break string there. If it is not a
  # space, identify the nearest previous space and break there. Analyze the next segment
  # and repeat. Ask each time whether the remaining segment is longer than wrap.length
  # before continuing.
  break_text <- function (text.frag, wrap.length) {
    # Idendify the locations of spaces.
    spaces <- sapply (1:(wrap.length+1), function (i) {
      i.char <- substr (text.frag, i, i)
      if (i.char == " ") { return (i) } else { return (NA) } })
    # Identify the last space in the string.
    break.char <- spaces [max (which (!is.na (spaces)))]
    # Break the string at the last space (and eliminate that space).
    frag1 <- substr (text.frag, 1, break.char - 1)
    frag2 <- substr (text.frag, break.char + 1, nchar (text.frag))
    return (c(frag1, frag2))
  }

  #--Check that the text even needs to be broken; if not, return it as is.
  if (nchar (text) <= wrap.length) {
    return (text) } else {

      #--Start a character vector with the entire text string. This will be replaced with
      # fragments of the string.
      all.frags <- text

      #--Break the text and collect the fragments. Continue breaking the second fragment
      # of each result until it is not longer than wrap.length. Collect all fragments.
      while (nchar (all.frags [length (all.frags) ]) >= wrap.length) {
        last.frag <- all.frags [length (all.frags)]
        # Break the last fragment at the space nearest the wrap.length.
        new.frags <- break_text (last.frag, wrap.length)
        # Replace the last fragment in all.frags with the first of new.frags.
        all.frags [length (all.frags)] = new.frags [1]
        # Add the second of new.frags.
        all.frags <- c(all.frags, new.frags [2])
      }

      #--Now recombine the fragments with \n for carriage returns. Return this.
      final.text <- paste (all.frags, collapse = "\n")
      return (final.text)
    }
}
