# install.packages("pracma")
library(writexl)
library(ggplot2)
library(dplyr)
library("pracma")
setwd("~/Desktop/PHD documents /Experiments/Objective 4_fastGC/Data processing")
#data <- read_excel("Batch2_200323_Analysis__Rebecca_fastGC.mldatx_results_ppbv_H3O.xlsx")
data <- read.csv("processedData4.csv")
# Multiple lines comment: cmd, shift and C


# --------  Imports ---------------------

source("functions.R")

# --------  Variables -------------------

# yeast_ids <- c("SafAle US-05", "SafAle WB-06")
yeast_ids <- c("US", "WB")
compound_ids <-c("CIT", "CLOL", "GE")
times <- c("0","6","12","18","24","30","36","42","48","54","60","66","72","78","84","90","96","102","108","114","120")
replicates <- c("1", "2", "3")
#mza <- c('ms21.0221','ms33.9944','ms34.0318','ms41.0400','ms43.0182','ms43.0555','ms48.0116','ms48.0521','ms57.0198','ms57.0710','ms61.0285','ms68.9960','ms69.0353','ms69.0705','ms81.0353','ms81.0719','ms103.0393','ms103.0740','ms135.0656','ms135.1036','ms137.0628','ms137.1348','ms139.0403','ms139.0883','ms139.1415','ms143.0373','ms143.0828','ms143.1362','ms144.9142','ms145.0525','ms145.1251','ms147.0596','ms147.1057','ms149.0287','ms149.0789','ms151.0971','ms153.0575','ms153.1232','ms155.0660','ms155.1371','ms157.1576','ms159.0632','ms159.1271','ms161.0729','ms161.1246','ms163.0516','ms163.0969','ms165.1074','ms169.0612','ms173.1556','ms175.0937','ms179.0920','ms179.1301','ms187.0672','ms189.0746','ms191.0848','ms193.0954','ms195.1123','ms199.1664','ms201.1873','ms202.9418','ms204.9488','ms205.0159','ms205.2116','ms207.1102')
mzs  <- c("ms48.0521", "ms81.0719", "ms135.1036", "ms137.1348", "ms139.1415", "ms153.0575", "ms153.1232",  "ms157.1576", "ms199.1664")

#these are only needed if you want to manually get the peak data for a single selected sample
yeast_id_index = 1
compound_id_index = 1
time_index = 1
replicate_index = 1
mz_index = 2

window_size <- 10 # Window size for the smoothed average
num_peaks <- 5 # Max Number of Peaks being detected
minpeakheight <- 0.04 # This needs to be tweaked. Peaks below will not be detected


#these variables do not need to be changed
smoothed_col <- "smoothed"
combined_df <- data.frame()
no_peaks_found_counter = 0

#---------- Automatic in a function -------
#currently set up to only get the data of a single mz value, which is determined by the mz_index
combined_df <- get_all_peaks(yeast_ids = yeast_ids,
                             compound_ids = compound_ids,
                             times = times,
                             replicates = replicates,
                             mzs = mzs, # This is how you can choose the mz you want. Change the mz_index above
                             smoothed_col = smoothed_col,
                             num_peaks = num_peaks,
                             window_size = window_size,
                             minpeakhight = minpeakhight,
                             combined_df = combined_df,
                             plot_data = TRUE)


# #---------- Manual Execution --------------
# 
# filtered_data <- filter_data(data = data,
#                              yeast_id = yeast_ids[yeast_id_index],
#                              compound_id = compound_ids[compound_id_index],
#                              replicate = replicates[replicate_index],
#                              time_point = times[time_index])
# 
# 
# unique_values <- unique(data$time)
# print(unique_values)
# 
# 
# filtered_data[smoothed_col] <- moving_average(filtered_data[mzs[mz_index]],window_size)
# 
# 
# #returns a matrix with each line be like this (height, position, start, end)
# highest_peaks <- find_highest_peaks(data = filtered_data,
#                                     smoothed_col = smoothed_col,
#                                     num_peaks = num_peaks,
#                                     window_size = window_size,
#                                     minpeakheight = minpeakheight)
# 
# 
# prepared_df <- prepare_dataframe(df = highest_peaks,
#                            yeast_id = yeast_ids[yeast_id_index],
#                            compound_id = compound_ids[compound_id_index],
#                            time_point = times[time_index],
#                            replicate = replicates[replicate_index],
#                            mz = mzs[mz_index]
#                            )
# 
# 
# p <- plot_spectrum_yeast(filtered_data, smoothed_col, mzs[mz_index])
# print(p)
# 




