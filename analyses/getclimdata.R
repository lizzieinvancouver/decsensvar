## Started 25 August 2025 ##
## By Lizzie ##

# housekeeping
rm(list=ls()) 
options(stringsAsFactors = FALSE)

setwd('/Users/lizzie/Documents/git/projects/treegarden/decsensvar/analyses')

d <- read.csv("input/lilacdataphen.csv")
dsubset <- subset(d, select=c("Site_ID", "Latitude", "Longitude", "Onset_Year"))
dlatlon <- dsubset[!duplicated(dsubset),]

dim(dlatlon)

# Now, start on getting the data from PRISM 
# (This seems the best, summary of many options here: https://climexp.knmi.nl/selectdailyfield2.cgi?id=someone@somewhere)
# https://docs.ropensci.org/prism/

if(FALSE){
library("prism")
prism_set_dl_dir('/Users/lizzie/Documents/git/projects/treegarden/decsensvar/analyses/prismdat')

get_prism_dailys(
  type = "tmean", 
  minDate = "2013-06-01", 
  maxDate = "2013-06-14", 
  keepZip = FALSE
)
}
## Hmm, these data are a hot mess. Is this really my best option?

## Next options ...
# I spent 30-60 mins with ChatGPT to get ideas, it led nowhere really ...
# We went around and around with getting data via NOAA nClimGrid-Daily
# but finally agreed with me that the API had changed and then it said it was now only online 1980+
# GPT claims that's the same year limit for PRISM so then we tried GHCN but my version of R does not suppport rnoaa 
# We tried GHCN and that just had so many issues, that I gave up. 

# I checked and PRISM does appear to drop out at 1981 for daily data
# I think our best bet is to use ERA or I could find an old harddive with the princeton data
# but that will end in 2006 or such I think (and is what we used in Nacho's paper, cite below)
# Sheffield, J., Goteti, G. & Wood, E. F. Development of a 50-year high-resolution global dataset of meteorological forcings for land surface modeling. J. Clim. 19, 3088–3111 (2006).