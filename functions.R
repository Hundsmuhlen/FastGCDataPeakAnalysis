#------- filter_data -----------------------------------------
filter_data <- function(data, yeast_id, compound_id, time_point, replicate_nr){
  filtered_data <- data[data$compound%in%c(compound_id)&
                          data$yeast%in%c(yeast_id)&
                          data$time%in%c(time_point)&
                          data$replicate%in%c(replicate_nr),]
  return(filtered_data)
}



#------- prepare_dataframe -----------------------------------------

prepare_dataframe <- function(df, yeast_id, compound_id, time_point, replicate, mz) {
  # Rename columns
  df <- as.data.frame(df)
  
  colnames(df) <- c("peak_height", "peak_spectrum", "peak_start", "peak_end")
  
  # Add 'peak_nr' column (equal to row indices)
  df$peak_nr <- seq_len(nrow(df))
  
  # Add fixed values
  df$yeast_id <- yeast_id
  df$compound_id <- compound_id
  df$time <- time_point
  df$replicate <- replicate
  df$mz <- mz
  
  return(df)
}


#------- find_highest_peaks -----------------------------------------

find_highest_peaks <- function(data, smoothed_col, num_peaks, window_size, minpeakheight){
  mz_smoothed_no_na <- replace(data[smoothed_col], is.na(data[smoothed_col]), 0)
  
  # return (Returns a matrix where each row represents one peak found. The first column gives the height, the second the position/index where the maximum is reached, the third and forth the indices of where the peak begins and ends — in the sense of where the pattern starts and ends.)
  # returns(height, position, start, stop)
  peak_indices <- findpeaks(mz_smoothed_no_na[[smoothed_col]],
                            minpeakheight = minpeakheight,
                            minpeakdistance = window_size, 
                            npeaks = num_peaks)
  #as there are only the indices of the peaks returned we need to add the lowest number of the Spectrum to the last 3 Field, position, start and end

  # Find the lowest value in the "Spectrum" column and convert it to a number value
  lowest_spectrum <- as.numeric(min(data$Spectrum))
  
  # Add the lowest spectrum value to the values in columns 2, 3, and 4 of the "peak_indices" data frame
  peak_indices[,2:4] <- peak_indices[,2:4] + lowest_spectrum
  
  #returns a matrix with each line be like this (height, position, start, end)
  return(peak_indices)
}


#------- moving_average -----------------------------------------

moving_average <- function(x, n) {
  
  result <- tryCatch({
    filter <- rep(1/n, n)
    stats::filter(x, filter, sides = 1)
  }, error = function(e) {
    # Log the error message
    # message("Error occurred: ", e$message)
    
    # Return NULL to indicate an error
    return(NULL)
  })
  
  return(c(result))
}
# moving_average <- function(x,n){
#   x <- as.numeric(x)
#   filter <- rep(1/n, n)
#   stats::filter(x,filter,sides=1)
#   
#   # head_avg <- sapply(seq_len(n-1), function(i){
#   #   mean(x[seq_len(i)])
#   # })
#   # tail_avg <- stats::filter(x,filter,sides=1)
#   # c(head_avg, tail_avg[-(1:(n-1))])
#   
# }



#------- plot_spectrum_yeast -----------------------------------------

plot_spectrum_yeast <- function(data, smoothed_col, mz){
  #Variables
  spectrum = "Spectrum"
  
  
  p<-ggplot(data, 
            aes_string(spectrum, 
                       smoothed_col, 
                       color="yeast",
                       shape="yeast",
                       id="compound")
            )+
    geom_line(size=.5)+
    theme_bw()+
    theme(panel.grid.minor = element_line(colour = "white", linewidth = .5), 
          panel.grid.major = element_line(colour = "white", linewidth = .5),
          plot.title = element_text(face = "italic", hjust = .5),
          text = element_text(size=20),
          legend.position = "right")+
    ggtitle(mz)+
    scale_color_manual(name="Yeast", values=c("#aa5400", "#084c61"))+
    #"grey",
    #ggplot shape
    #"green4","mediumorchid4"
    scale_shape_manual(name="Yeast", values=c(1, 2, 3, 4, 5, 16))+
    #"black", "grey",
    ylab("Peak Area")+
    xlab("Spectrum")+
    # facet_wrap(~ Compound_id, ncol=1)
    # facet_wrap( ~ id_yeast_new, ncol=2)
    facet_grid(time ~ compound)
  
  return(p)
}

#------- get_all_peaks -----------------------------------------


get_all_peaks <- function(yeast_ids, compound_ids,times, replicates, mzs, smoothed_col, num_peaks, window_size, minpeakhight, combined_df, plot_data=FALSE){
  for (yeast in yeast_ids){
    for (compound in compound_ids){
      for (t in times){
        for (r in replicates){
          for (mz in mzs){
  
            filtered_data <- filter_data(data = data,
                                         yeast_id = yeast,
                                         compound_id = compound,
                                         replicate = r,
                                         time_point = t
                                         )
  
            filtered_data[smoothed_col] <- moving_average(filtered_data[mz],
                                                          window_size)
  
            # Check if the new column exists in the filtered_data data frame
            column_exists <- with(filtered_data, exists(smoothed_col))
  
            if (!column_exists) {
              message("Skipping this iteration because no data has been smoothed, becuase this combination of yeast, compound and mz does not exist.")
              next
            }
  
  
            #returns a matrix with each line be like this (height, position, start, end)
            highest_peaks <- find_highest_peaks(data = filtered_data,
                                                smoothed_col = smoothed_col,
                                                num_peaks = num_peaks,
                                                window_size = window_size,
                                                minpeakheight = minpeakheight)
            if (is.null(highest_peaks)){
              message("------------- NO PEAK FOUND! --------------------")
              no_peaks_found_counter = no_peaks_found_counter + 1
              next
            }
  
            prepared_df <- prepare_dataframe(df = highest_peaks,
                                             yeast_id = yeast,
                                             compound_id = compound,
                                             time_point = t,
                                             replicate = r,
                                             mz = mz
                                            )
  
            # Add the found peaks to the combined_df which gets exported.
            if (exists("combined_df") && is.data.frame(combined_df) && nrow(combined_df)==0){
              combined_df <- prepared_df
            } else{
            combined_df <- rbind(combined_df, prepared_df)
            }
            
            if (plot_data){
              #If you want to change the look of the plot, change the parameters in the "plot_spectrum_yeast" function above
              p <- plot_spectrum_yeast(filtered_data, smoothed_col, mz)
              ggsave(file=paste0(mz, "_", yeast, "_", compound, "_", t, "_", r, ".pdf"), 
                     p, 
                     width = 20, 
                     height = 10,
                     units = "cm",
                     limitsize = FALSE)
            }
          }
        }
      }
    }
  }
  return (combined_df)
  write_xlsx(combined_df, "combined_peaksms155_1438.xlsx")
  
}

