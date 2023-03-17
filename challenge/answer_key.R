# Answer Key for the Challenge at the end of the tutorial
# Created on 6 Dec. 2022 by Markus Skelton

# Libraries
library(tidyverse)
library(geosphere)
library(stringdist)

#### Looking at Data ####

# load in example data sets
mass1 <- read.csv("challenge/mass_cities1.csv")

mass2 <- read.csv("challenge/mass_cities2.csv")

# merge files on just name alnge
place_perfmatch <- inner_join(mass1, mass2, by = "city") %>% 
  rename(lng_county = lng.x) %>% 
  rename(lat_county = lat.x) %>%
  rename(lng_pop = lng.y) %>%
  rename(lat_pop = lat.y)

#### Making the Dist Matrix ####
# make a data set of the unmatched places
nomatch_county <- subset(mass1, !(mass1$city %in% place_perfmatch$city))
nomatch_pop <- subset(mass2, !(mass2$city %in% place_perfmatch$city))

nomatch <- bind_rows(nomatch_county, nomatch_pop)

# make a data frame that just has the lat and lng columns
matrixmatch <- select(nomatch, lng, lat)

# make the distance matrix using the distm function
distmatrix <- distm(matrixmatch, fun=distGeo)

# The matrix computes distances in meters by default
# set all values in the matrix that are greater than 1400 m (or roughly 0.86 mi) to zero
distmatrix[distmatrix > 1600] <- 0

# turn the matrix into a data frame
distmatrix_df <- as.data.frame(distmatrix)

# saves location of every remaining non-zero value in the matrix
mat <- which(distmatrix_df[-43] > 0, arr.ind = TRUE)

# sets the values of the non-zero values to be the name of the column
distmatrix_df[-43][mat] <- names(distmatrix_df)[-43][mat[, 2]]

# Creates an empty data frame for the loop
col_match <- data.frame()

# a for loop that compiles all of the remaining matches from the matrix
for(i in 1:length(distmatrix_df)){
  temp_row <- slice(distmatrix_df, i)                  # take the ith row from the matrix df
  
  temp_row <-  temp_row[, colSums(temp_row != 0) > 0]  # saves the name of the nonzero value (which is the column name)
  
  temp_row <- as.data.frame(temp_row)                  # turns it back into a dataframe
  
  # a nested for loop that names the 
  for(k in 0:ncol(temp_row)){                          # iterate over the number of columns in temp row
    # ideally there is only one column, the for loop is in case there are more than one
    colnames(temp_row)[k] <- paste0("C", k)            # name the columns to be C1, C2, etc
    
  }
  
  temp_row$ownname <- paste0("V", i)                   # Creates a new column that includes it's original position in the matrix
  
  col_match <- bind_rows(col_match, temp_row)
  
  rm(temp_row)
}

# bring ownname column to front (for simplicity)
col_match <- relocate(col_match, ownname)

# just keep all of the place names from the unmatched list of locations
labels <- select(nomatch, city)

# create a column that includes 'vlabels' or labels that follow the same patter as the matrix matches
labels$vlabel <- paste0("V", seq.int(nrow(labels)))

# create a new matches data frame that joins on the names of the locations and removes the matrix 'vlables'
new_matches <- left_join(col_match, labels, by = c("ownname" = "vlabel")) %>% 
  rename(city_own = city) %>% 
  left_join(., labels, by = c("C1" = "vlabel")) %>% 
  rename(., city_match = city) %>% 
  select(city_own, city_match)

# create a string distance variable 
new_matches$strdist <- stringdist(new_matches$city_own, new_matches$city_match, method = "jw")

# filter out the towns that have a good match (a low string distance)
# this is a qualitative judgement, I suggest sorting by and looking at looking the 
# string distances and deciding at what point the names look too dissimilar 
# to you and use that string distance as a threshold by which to filter
new_matches_strng <- new_matches[which(new_matches$strdist < .16),]

# take a look at the weak matches and do some research! Searching up the name of the town
# and state and the words 'name change' or 'original name' might be enough to see whether these towns are really meant to match
# if you decide they are meant to match, you can either manually change one of the data sets and force the names to match,
# or ignore the string distance measure if you are confident that all of the towns are meant to match no matter the name
new_matches_weak <- new_matches[which(new_matches$strdist >= .16),]


# rename lat/lng vars across dfs to distinguish them when merging
mass1 <- mass1 %>% 
  rename(lat_county = lat) %>% 
  rename(lng_county = lng)

mass2 <- mass2 %>% 
  rename(lat_pop = lat) %>% 
  rename(lng_pop = lng)

place_newmatch <- left_join(new_matches, mass1, by = c("city_own" = "city")) %>% 
  left_join(., mass2, by = c("city_match" = "city")) %>%
  filter(!is.na(county_fips)) %>% 
  rename(city = city_own)

# bind together the new matches with the perfect matches from before
place_full <- bind_rows(place_perfmatch, place_newmatch)

# save the fully merged file
write.csv(place_full, "challenge/place_fullmerge_mass.csv", row.names = FALSE)



