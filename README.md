# Data Processing for Fast-GC PTR-ToF-MS Analysis

This repository contains scripts to process GC-MS data for yeast fermentation studies. The analysis involves extraction of specific peaks from the spectral data for compounds of interest.

## Scripts and Functions

### Main Script

The main script (`main.R`) reads a dataset and calls functions from `functions.R` to perform data processing and peak detection. The main operations include:

- Reading data
- Setting global variables such as `yeast_ids`, `compound_ids`, `times`, `replicates` and `mzs` (m/z values of interest)
- Calling the function `get_all_peaks()` that performs data filtering, smoothing, peak detection, and data frame preparation for all combination of yeast, compound, time, and replicates specified by the global variables. 

### Functions

`functions.R` includes the following functions:

- `filter_data()`: filters the input data for specified parameters (yeast_id, compound_id, time_point, replicate)
- `prepare_dataframe()`: prepares a data frame with the peaks' information for a specific sample
- `find_highest_peaks()`: detects the highest peaks in the smoothed spectrum for a specific sample
- `moving_average()`: calculates the moving average for the input vector
- `plot_spectrum_yeast()`: creates a plot of the smoothed spectrum and saves it as a PDF
- `get_all_peaks()`: carries out data processing and peak detection for all combinations of yeast, compound, time, and replicates. 

## Usage

To use the script and functions, follow these steps:

1. Clone this repository to your local machine.
2. Navigate to the directory containing the repository via your R environment.
3. Make sure you have the necessary libraries installed (`writexl`, `ggplot2`, `dplyr`, `pracma`). If not, install them using the `install.packages()` function.
4. Open the main script and set the working directory to the location where your input data file (`processedData4.csv`) resides.
5. Adjust the global variables (`yeast_ids`, `compound_ids`, `times`, `replicates` and `mzs`) as needed.
6. Run the script. The function `get_all_peaks()` will process the data and extract the peaks for the conditions specified by the global variables.

If you want to generate plots for each condition, set the `plot_data` parameter in `get_all_peaks()` to `TRUE`.

## Output

The `get_all_peaks()` function returns a data frame containing the peaks detected for each combination of yeast, compound, time, and replicates. If `plot_data` is set to `TRUE`, it will also generate a PDF plot for each condition and save it to your working directory.

## License

This project is licensed under the MIT License.

## Contact

If you have any questions or encounter any issues, please open an issue in this repository.

## Author

Jan Effenberger 2023
