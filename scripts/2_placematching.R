# Town Matching Script that includes the code that will be published in the tutorial
# Created on 4 Dec. 2022 by Markus Skelton

# install packages
install.packages("geosphere")
install.packages("stringdist")

# Libraries
library(tidyverse)
library(geosphere)
library(stringdist)

#### Looking at Data ####

# load in example data sets
placeid <- read.csv("data/practice_data/placeid_coords.csv")

placecat <- read.csv("data/practice_data/placecat_coords.csv")

# summaries
str(placeid)
head(placeid)

str(placecat)
head(placecat)

# merge files on just name alone
place_perfmatch <- inner_join(placeid, placecat, by = "Place.Name") %>% 
                   rename(Lon_id = Lon.x) %>% 
                   rename(Lat_id = Lat.x) %>%
                   rename(Lon_cat = Lon.y) %>%
                   rename(Lat_cat = Lat.y)

# save data frame
write.csv(place_perfmatch, "outputs/place_perfmatch.csv")

# Something doesn't look right here, we have 74 locations, but only 46 were able to match
# In this case, by looking at the two dfs we can see how the remaining 28 are meant to match,
# But sometimes you have much more than 28 unmatched locations, as place names vary across different
# data sets due to name changes over time or mistakes/personal choices by the enumerators.


#### Making the Dist Matrix ####
# make a data set of the unmatched places
nomatch_id <- subset(placeid, !(placeid$Place.Name %in% place_perfmatch$Place.Name))
nomatch_cat <- subset(placecat, !(placecat$Place.Name %in% place_perfmatch$Place.Name))

nomatch <- bind_rows(nomatch_id, nomatch_cat)

# make a data frame that just has the lat and lon columns
matrixmatch <- select(nomatch, Lon, Lat)

# make the distance matrix using the distm function
distmatrix <- distm(matrixmatch, fun=distGeo)

png("outputs/pixel_mat_1.png")
image(distmatrix, useRaster=TRUE, axes=FALSE)
dev.off()

# The matrix computes distances in meters by default
# set all values in the matrix that are greater than 1400 m (or roughly 0.86 mi) to zero
distmatrix[distmatrix > 1400] <- 0

png("outputs/pixel_mat_2.png")
image(distmatrix, useRaster=TRUE, axes=FALSE)
dev.off()

# turn the matrix into a data frame
distmatrix_df <- as.data.frame(distmatrix)

# saves location of every remaining non-zero value in the matrix
mat <- which(distmatrix_df[-57] > 0, arr.ind = TRUE)

# sets the values of the non-zero values to be the name of the column
distmatrix_df[-57][mat] <- names(distmatrix_df)[-57][mat[, 2]]

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
labels <- select(nomatch, Place.Name)

# create a column that includes 'vlabels' or labels that follow the same patter as the matrix matches
labels$vlabel <- paste0("V", seq.int(nrow(labels)))

# create a new matches data frame that joins on the names of the locations and removes the matrix 'vlables'
new_matches <- left_join(col_match, labels, by = c("ownname" = "vlabel")) %>% 
               rename(Place.Name_own = Place.Name) %>% 
               left_join(., labels, by = c("C1" = "vlabel")) %>% 
               rename(., Place.Name_match = Place.Name) %>% 
               select(Place.Name_own, Place.Name_match)

# create a string distance variable 
new_matches$strdist <- stringdist(new_matches$Place.Name_own, new_matches$Place.Name_match, method = "jw")

# calculating the string distance can be helpful when you're not sure whether every location necessarily has a match
# however, it is not perfect. As you can see, for shorter words, the string distance will be high when there is a difference
# even if the names are very similar.

# rename Lat/Lon vars across dfs to distinguish them when merging
placeid <- placeid %>% 
           rename(Lat_id = Lat) %>% 
           rename(Lon_id = Lon)

placecat <- placecat %>% 
            rename(Lat_cat = Lat) %>% 
            rename(Lon_cat = Lon)

place_newmatch <- left_join(new_matches, placeid, by = c("Place.Name_own" = "Place.Name")) %>% 
                  left_join(., placecat, by = c("Place.Name_match" = "Place.Name")) %>%
                  filter(!is.na(Place.ID)) %>% 
                  rename(Place.Name = Place.Name_own)
  
# save the matrix matches
write.csv(place_newmatch, "outputs/place_matrixmatch.csv")

# bind together the new matches with the perfect matches from before
place_full <- bind_rows(place_perfmatch, place_newmatch)

# save the fully merged file
write.csv(place_full, "outputs/place_fullmerge.csv")
