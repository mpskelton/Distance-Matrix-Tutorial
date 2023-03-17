# Scripts
This folder contains the two scripts used to make tutorial (besides the challenge answer key script found in `Challenge`).

The scripts are
- `1_databuilding.R`
- `2_placematching.R`

### `1_databuilding.R`
This script creates the practice data sets based on Harry Potter locations that are used throughout the tutorial. The script also makes the two challenge data sets that are stored in the `Challenge` folder.

The inputs for this script are
- `HP_places.csv`
- `uscities.csv`

and the script creates
- `coords_alt.csv`
- `coords.csv`
- `placecat_coords.csv`
- `placeid_coords.csv`

The coordinates are generated randomly by the script since they are not attached to real-world locations, but I saved the generated coordinates and altered the script to read and use the two `coords` files since otherwise the data would change every time the script is run. The original code can be found in the script but commented out.

### `2_placematching.R`
This script creates the distance matrix and merges the two files `placecat_coords.csv` and `placeid_coords.csv`. All of the code copied into the tutorial document can be found in this script (except for the `setwd()` command which is only in the tutorial document since not everyone will necessarily be working from a github repository).

The inputs are
- `placecat_coords.csv`
- `placeid_coords.csv`

and the outputs (found in the `Outputs` folder) are
- `pixel_mat_1.png`
- `pixel_mat_2.png`
- `place_fullmerge.csv`
- `place_matrixmatch.csv`
- `place_perfmatch.csv`
