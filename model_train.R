suppressWarnings(suppressMessages(require(here)))
suppressWarnings(suppressMessages(require(xgboost)))
suppressWarnings(suppressMessages(require(data.table)))
setwd(here())

source("functions.R")

# data preprocess
dt <- data.table(combine_all())

dt <- dt[,-c(1,2,7,10)]
dt <- dt[which(dt$km >= 5000),] # More than 5000 km.
dt <- dt[which(as.numeric(as.character(dt$year)) >= 2000),] # Newer than 2000.

dt$old <- as.numeric(Sys.Date()-dt$date)
dt <- dt[,-c("date")]
dt$year <- as.numeric(substr(Sys.Date(),1,4)) - as.numeric(as.character(dt$year))


# Train xGBoost model on dataset
car_train(portion = 0.7, nround = 20000)
