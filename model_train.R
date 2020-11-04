suppressWarnings(suppressMessages(require(here)))
suppressWarnings(suppressMessages(require(xgboost)))
suppressWarnings(suppressMessages(require(data.table)))
setwd(here())

source("functions.R")

# data preprocess
ege <- data.table(combine_all())

ege <- ege[,-c(1,2,7,10)]
ege <- ege[which(ege$km >= 5000),]
ege <- ege[which(as.numeric(as.character(ege$year)) >= 2000),]

ege$old <- as.numeric(Sys.Date()-ege$date)
ege <- ege[,-c("date")]
ege$year <- as.numeric(substr(Sys.Date(),1,4)) - as.numeric(as.character(ege$year))

car_train(portion = 0.7, nround = 20000)