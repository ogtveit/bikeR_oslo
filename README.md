# bikeR_oslo

R script to fetch all Oslo bysykkel stations, along with avaliable bikes and free bike docks.

Utilize the API described here: https://oslobysykkel.no/apne-data/sanntid

The script use the libraries _httr_, _jsonlite_ and _dplyr_. When run it will try to install these if not installed.

## To run script 

### Windows command line
Run Rscript.exe with bikeR_oslo.R as argument, e.g:

> C:\"Program Files"\R\R-3.6.1\bin\Rscript.exe \path\to\script\bikeR_oslo.R

### RStudio
Open bikeR_oslo.R in RStudio
Select all lines (CTRL + A)
Execute selected lines (CTRL + Enter)