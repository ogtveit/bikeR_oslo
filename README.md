# bikeR_oslo version 0.2

R script to fetch and show all Oslo bysykkel stations, along with avaliable bikes and free bike docks for each. Utilizes the API described here: https://oslobysykkel.no/apne-data/sanntid

bikeR_oslo have two versions: a [Shiny](https://shiny.rstudio.com/) webapp and a regular R script

- app.R contains the Shiny version, will start the server when run
- bikeR_oslo.R contains a simple script that can run in a terminal

The R script use the libraries _httr_, _jsonlite_ and _dplyr_. When run it will try to install these if not installed. The Shiny app requires the libraries _shiny_, _shinydashboard_ and _leaflet_ in addition. 

If automatic package installation fails, run in an R session / RStudio:
> install.packages('dplyr', 'httr', 'jsonlite', 'shiny', 'shinydashboard', 'leaflet')

## To run 
The Shiny webapp is demonstrated at: https://olegt.shinyapps.io/biker_oslo/ 

#### RStudio
Open bikeR_oslo.R or app.R in [RStudio](https://rstudio.com/)

Execute all lines (CTRL + SHIFT + Enter)

#### Windows / UNIX terminal
With R installed, run Rscript.exe / Rscript with bikeR_oslo.R or app.R as argument, e.g:

> C:\\"Program Files"\R\R-3.6.1\bin\Rscript.exe \path\to\script\bikeR_oslo.R

> /usr/bin/env Rscript path/to/bikeR_oslo.R

## Testing

Testing requires the libraries _testthat_, _here_ and _httptest_. To run all tests execute '.\tests\testthat.R'. Either open tests/testthat.R in RStudio and run all (CTRL + SHIFT + Enter), or run in terminal:

> C:\\"Program Files"\R\R-3.6.1\bin\Rscript.exe \path\to\script\tests\testthat.R

> /usr/bin/env Rscript path/to/tests/testthat.R