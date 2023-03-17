# Data Building Script that constructs the data I will use for this tutorial
# Created on 3 Dec. 2022 by Markus Skelton


# Libraries
library(tidyverse)


# load in data
places <- read.csv("data/HP_Places.csv")

#### Building the practice data frames ####
# split the info into the places data set into two dfs
placeid <- places %>% 
           select(-c("Place.Category"))

placecat <- places %>% 
            select(-c("Place.ID"))

# create data frame of random coordinates to merge onto places
# coords_lat <- as.data.frame(matrix(runif(n=74, min=-90, max=90), nrow=74))
# coords_lon <- as.data.frame(matrix(runif(n=74, min=-180, max=180), nrow=74))

# coords <- cbind(coords_lon, coords_lat)

# change names to be latitude and longitude (even though the values are arbitrary)
# colnames(coords) <- c("Lon", "Lat")

# save coords df because this will change each time the line above is run
# write.csv(coords, "data/coords.csv", row.names = FALSE)

# read in saved coords instead of generating new ones so the values don't change
coords <- read.csv("data/coords.csv")

# Merge onto the placeid data frame
placeid_coord <- cbind(placeid, coords)

# alter coordinates in coords data frame for an alternate coordinates set
# coords_alt <- coords %>% 
#              mutate(Lat = Lat + runif(n=1, min=0.001, max=0.01)) %>% 
#              mutate(Lon = Lon + runif(n=1, min=0.001, max=0.01))


# save coords_alt for same reason as coords
# write.csv(coords_alt, "data/coords_alt.csv", row.names = FALSE)

# load in saved coords_alt
coords_alt <- read.csv("data/coords_alt.csv")

# Merge coords_alt onto placecat data frame
placecat_coord <- cbind(placecat, coords_alt)

# change names of places slightly in placecat_coords
placeid_coord$Place.Name <- str_replace_all(placeid_coord$Place.Name, c(" and " = " & "))


placecat_coord$Place.Name <- str_replace_all(placecat_coord$Place.Name, 
                                             c("&" = "and", "'" = "", "-" = " ",
                                               "4" = "Four", "12" = "Twelve",
                                               "The " = "", "Headmaster" = "Dumbledore",
                                               "Classroom" = "Class"))

# save datasets
write.csv(placeid_coord, "data/practice_data/placeid_coords.csv", row.names = FALSE)
write.csv(placecat_coord, "data/practice_data/placecat_coords.csv", row.names = FALSE)


#### Create Challenge Data Sets ####
# read in data set for challenge
us_cities <- read.csv("data/uscities.csv")

# subset to just massachusetts cities and select variables
mass_cities <- us_cities[which(us_cities$state_id == "MA"),] %>% 
               select(c("city", "county_fips", "county_name", "lat", "lng", 
                        "population", "density", "id"))
# make one side of the merge
mass_cities_p1 <- mass_cities %>% 
                  select(-c("population", "density", "id"))

# make the other side of the merge
mass_cities_p2 <- mass_cities %>% 
                  select(-c("county_fips", "county_name")) %>% 
                  mutate(lat = lat + runif(n=1, min=0.005, max=0.01)) %>% 
                  mutate(lng = lng + runif(n=1, min=0.005, max=0.01))

mass_cities_p2$city <- str_replace_all(mass_cities_p2$city, c("borough" = "boro",
                                                              "Center" = "", "-" = " ",
                                                              "Town" = "", "Falls" = "",
                                                              "Lowell" = "East Chelmsford",
                                                              "Lawrence" = "Merrimac", "Revere" = "North Chelsea"))


# save two challenge data sets
write.csv(mass_cities_p1, "challenge/mass_cities1.csv", row.names = FALSE)
write.csv(mass_cities_p2, "challenge/mass_cities2.csv", row.names = FALSE)


