# sahi1000den
This repository contains the web scraping methods for the second hand cars on www.sahibinden.com which is a well-known Turkish electronic second-hand market. This tool can fetch last 1000 data for each model.

### Clone the repository (MacOS / Linux)
```sh
$ git clone https://github.com/egeor90/sahi.git && cd sahi
```

### Prerequisites
This file will automatically install `tidyverse`, `rvest`, `stringr`, `rebus`, `lubridate`, `dplyr`, `here`, `xgboost` packages. 
If you have any trouble with installation of any package above, please make sure if required packages have been installed. You can install packages manually as follows.

Install packages via Rscript:
```r
install.packages(c(“tidyverse”,"rvest","stringr","rebus","lubridate","dplyr","here","xgboost"))
```

Install packages via Terminal (for Linux):
```sh
$ sudo su - \
  -c "R -e \"install.packages(‘rebus’, repos='https://cran.rstudio.com/')\""
```

## Using with Terminal (for MacOS & Linux)

### Fetch data
```sh
$ cd "/path/to/file/"
$ sudo Rscript sahibinden.R
```

Then it will ask the car brand and the model. Type them (it is not case-sensitive). Here is an example given:

```
Please enter the brand: Toyota
Please enter the model: Corolla

[1] "Please wait! This process can take several minutes."
This process took 180.76 seconds, with 983 results

Successful! Please locate the file here:
/home/ege/sahibinden/data/toyota-corolla.csv
```

### Train xGBoost model
```sh
$ Rscript model_train.R
```


### Prediction of second-hand car price
```sh
$ Rscript predict.R
```

Then fill the inputs in following way:
```sh
Brand: Audi
Model: A3
Year: 2018
Km: 10000
Color: Mavi
City: Ankara
Old (yyyy-mm-dd): 2020-11-02
[1] 321218.3
```

Parameters are not case sensitive. Parameter attributes are as follows:  
`Brand`: Car brand.  
`Model`: Model of the brand.  
`Year`: Car's production year.  
`Km`: Km of the car.  
`Color`: Color of the car. Currently in Turkish.  
`City`: City of selling.  
`Old`: The date of publication. It should be in *YYYY-MM-DD* format. For instance, `2020-11-02`, `2020-10-30`.


## Execution without `Rscript` command each time (optional - MacOS & Linux)
If you want to execute the code without writing `Rscript` command each time, you may follow the next steps:

- Run `exec.sh` file.

```sh
$ bash exec.sh
```

- Then, check if R files in current working directory has the path for Rscript. In the first line of each file, there should exist a path like `#!/usr/local/bin/Rscript`:

```sh
$ cat functions.R | head -n5
$ cat predict.R | head -n5
$ cat model_train.R | head -n5
$ cat sahibinden.R | head -n5
```

- After you make sure that .R files contain the execution path of Rscript lines above, you can run each file as follows:

```sh
$ ./sahibinden.R
$ ./model_train.R
$ ./predict.R
```
