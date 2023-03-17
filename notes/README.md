# Notes for Tutorial Assignment

This document is for storing my notes, brainstorms, and to-do lists for this assignment.

### Topic
The topic for my tutorial is using distance matrices to match locations. In the past, I have encountered multiple data sets that include information on a set of locations but sometimes the names of the locations differ slightly (or greatly) across data sets. The solution I found for matching the locations with each other across data sets was using their coordinates to create a matrix that calculates the distance between every two locations. When the locations are matched with themselves in the matrix the distance value will be zero, and for the rest of the locations a value measured in miles (by default) is shown. Usually data sets have slightly different coordinate values for something like a town but the difference will be very small, so once the distance matrix is computed, you can filter out all matches that are above a threshold you set. For example, you can only keep the matches that are within a mile of each other under the assumption that different coordinates for the 'center' of a town will be within a mile of each other.

The distance matrix, however, can also come in handy if you are interested in grouping certain locations. Maybe you don't want to match the locations to each other but you want a convenient way to group all of them by region. The distance matrix can come in handy for this as well by grouping the locations together. There will be some more complexity with this since one location could match with two different towns if it is between them but I believe I will be able to present workarounds for this situation.

### Brainstorming


### To-Do List
- Make a script that makes a data set for the tutorial (or find an easy to use data set online)
- Make a script that computes the matrix
- Make a description of the packages used
- Find a list of extra reading sources
- Annotate the code
- Write out the tutorial in the preferred format


