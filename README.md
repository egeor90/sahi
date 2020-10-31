# sahi1000’den
This repository contains the web scraping methods for the second hand cars on www.sahibinden.com which is a well-known Turkish electronic second-hand market.

## Prerequisites
This file will automatically install `tidyverse`, `rvest`, `stringr`, `rebus`, `lubridate`, `dplyr`, `here` packages. If you have any trouble with them, please make sure if required packages have been installed. 

Install packages via Rscript:
```r
install.packages(c(“tidyverse”,"rvest","stringr","rebus","lubridate","dplyr","here"))
```

Install packages via Terminal (for Linux):
```sh
$ sudo su - \
  -c "R -e \"install.packages(‘rebus’, repos='https://cran.rstudio.com/')\""
```


## Using with Terminal (for MacOS & Linux)

```sh
$ cd "/path/to/file/"
$ Rscript sahibinden.R
```

Then it will ask the car brand and the model. Type them (it is not case-sensitive). Here is an example given:
```
Please enter the brand: Toyota
Please enter the model: Corolla

[1] "Please wait! This process can take several minutes."
This process took 20.15 seconds

Successful! Please locate the file here:
/Users/Ege/sahibinden/data/camaro.csv
```
