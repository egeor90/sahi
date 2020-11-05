options(warn=-1)
Sys.setlocale("LC_ALL", 'en_US.UTF-8')

pck_ <- c("tidyverse", "rvest", "stringr", "rebus", "lubridate", "dplyr", "here", "stringr")

pck <- pck_[!(pck_ %in% installed.packages()[,"Package"])]
if(length(pck)){
  cat(paste0("Installing: ", pck, "\n"))
  install.packages(pck, repos = 'http://cran.us.r-project.org')
}


suppressWarnings(suppressMessages(invisible(lapply(pck_, require, character.only = TRUE))))

setwd(here::here())


get_max_page <- function(html){
  max_page <- substr(as.character(html %>% html_nodes('.mbdef') %>% html_text() %>% unlist()), 
                     8, 
                     nchar(as.character(html %>% html_nodes('.mbdef') %>% html_text() %>% unlist())))
  max_page <- as.numeric(gsub(" sayfa i.*","",max_page))
  return(max_page)
}


get_captions <- function(html){
  captions <- html %>% html_nodes('.classifiedTitle') %>% html_text() %>% str_trim() %>% unlist()
  return(captions)
}


get_links <- function(html){
  links_ <- NA
  for(i in 1:length(html %>% html_nodes('.classifiedTitle') %>% html_attrs() %>% str_trim() %>% unlist())){
    links_[i] <- paste0("https://www.sahibinden.com",unlist(html %>% html_nodes('.classifiedTitle') %>% html_attrs())[3*i])
  }
  return(links_)
}


get_yrkmcol <- function(html){
  year_ <- km_ <- color_ <- price_ <- NA
  for(i in 1:length(captions)){
    year_[i] <- (html %>% html_nodes('.searchResultsAttributeValue') %>% html_text() %>% str_trim() %>% unlist())[3*i-2]
    km_[i] <- (html %>% html_nodes('.searchResultsAttributeValue') %>% html_text() %>% str_trim() %>% unlist())[3*i-1]
    color_[i] <- (html %>% html_nodes('.searchResultsAttributeValue') %>% html_text() %>% str_trim() %>% unlist())[3*i]
  }
  assign("year_",year_, envir = .GlobalEnv)
  assign("km_",km_, envir = .GlobalEnv)
  assign("color_",color_, envir = .GlobalEnv)
}

get_price <- function(html){
  price_ <- (html %>% html_nodes('.searchResultsPriceValue') %>% html_text() %>% str_trim() %>% unlist())
  price_ <- gsub('\\.','',price_)
  price_unit <- unlist(lapply(strsplit(price_, ' ', fixed = TRUE), '[', 2))
  price_ <- as.numeric(gsub(" .*","",price_))
  assign("price_",price_, envir = .GlobalEnv)
  assign("price_unit",price_unit, envir = .GlobalEnv)
}

get_date <- function(html){
  date_ <- (html %>% html_nodes('.searchResultsDateValue') %>% html_text() %>% str_trim() %>% unlist())
  date_ <- gsub(" ","",gsub("\n","",date_))
  
  for(i in 1:length(date_)){
    if(substr(date_[i],3,nchar(date_[i])-4) == "Ekim"){
      date_[i] <- as.Date(gsub("Ekim","-10-",date_[i]), format = "%d-%m-%Y")
    }else if(substr(date_[i],3,nchar(date_[i])-4) == "Kasım"){
      date_[i] <- as.Date(gsub("Kasım","-11-",date_[i]), format = "%d-%m-%Y")
    }else if(substr(date_[i],3,nchar(date_[i])-4) == "Eylül"){
      date_[i] <- as.Date(gsub("Eylül","-09-",date_[i]), format = "%d-%m-%Y")
    }else if(substr(date_[i],3,nchar(date_[i])-4) == "Ağustos"){
      date_[i] <- as.Date(gsub("Ağustos","-08-",date_[i]), format = "%d-%m-%Y")
    }else if(substr(date_[i],3,nchar(date_[i])-4) == "Temmuz"){
      date_[i] <- as.Date(gsub("Temmuz","-07-",date_[i]), format = "%d-%m-%Y")
    }else if(substr(date_[i],3,nchar(date_[i])-4) == "Haziran"){
      date_[i] <- as.Date(gsub("Haziran","-06-",date_[i]), format = "%d-%m-%Y")
    }else if(substr(date_[i],3,nchar(date_[i])-4) == "Mayıs"){
      date_[i] <- as.Date(gsub("Mayıs","-05-",date_[i]), format = "%d-%m-%Y")
    }else if(substr(date_[i],3,nchar(date_[i])-4) == "Nisan"){
      date_[i] <- as.Date(gsub("Nisan","-04-",date_[i]), format = "%d-%m-%Y")
    }else if(substr(date_[i],3,nchar(date_[i])-4) == "Mart"){
      date_[i] <- as.Date(gsub("Mart","-03-",date_[i]), format = "%d-%m-%Y")
    }else if(substr(date_[i],3,nchar(date_[i])-4) == "Şubat"){
      date_[i] <- as.Date(gsub("Şubat","-02-",date_[i]), format = "%d-%m-%Y")
    }else if(substr(date_[i],3,nchar(date_[i])-4) == "Ocak"){
      date_[i] <- as.Date(gsub("Ocak","-01-",date_[i]), format = "%d-%m-%Y")
    }else if(substr(date_[i],3,nchar(date_[i])-4) == "Aralık"){
      date_[i] <- as.Date(gsub("Aralık","-12-",date_[i]), format = "%d-%m-%Y")
    }
  }
  
  date_ <- as.Date(as.numeric(date_), origin = "1970-01-01")
 
  return(date_)
}


get_location <- function(html){
  location_city <- gsub(".*\\n","",as.character((html %>% html_nodes('.searchResultsLocationValue'))))
  location_city <- trimws(location_city, which = c("both", "left", "right"), whitespace = "[ \t\r\n]")
  location_city <- gsub("</td>","",location_city)
  location_city <- gsub("<br>",":",location_city)
  location_district <- unlist(lapply(strsplit(location_city, ':', fixed = TRUE), '[', 2))
  location_city <- gsub(":.*","",location_city)
  assign("location_city",location_city, envir = .GlobalEnv)
  assign("location_district",location_district, envir = .GlobalEnv)
}

combine_all <- function(){
  suppressWarnings(suppressMessages(require(here)))
  setwd(paste0(here(),"/data"))
  
  all_cars <- lapply(list.files(pattern="*.csv"), 
                     function(x) read.csv(x,
                                          fill=TRUE, 
                                          header=TRUE, 
                                          quote="", 
                                          sep=";", 
                                          stringsAsFactors = FALSE, 
                                          encoding="UTF-8"))
  
  
  for(i in 1:length(all_cars)){
    names(all_cars)[i] <- tolower(all_cars[[i]][,12][1])
  }
  
  
  df <- do.call(rbind.data.frame, all_cars)
  rownames(df) <- as.numeric(1:nrow(df))
  
  df$caption <- as.character(df$caption)
  df$link <- as.character(df$link)
  df$year <- as.factor(df$year)
  df$km <- as.numeric(df$km)
  df$color <- as.factor(df$color)
  df$price <- as.numeric(df$price)
  df$price_unit <- as.factor(df$price_unit)
  df$date <- as.Date(df$date)
  df$city <- as.factor(df$city)
  df$district <- as.factor(df$district)
  df$brand <- as.factor(df$brand)
  df$model <- as.factor(df$model)
  
  df <- na.omit(df)
  return(df)
}


car_train <- function(portion = 0.7, nround = 20000, output_file = "xgb.model"){

  dt <- data.table::data.table(combine_all())
  
  dt <- dt[,-c(1,2,7,10)]
  dt <- dt[which(dt$km >= 5000),]
  dt <- dt[which(as.numeric(as.character(dt$year)) >= 2000),]
  
  dt$old <- as.numeric(Sys.Date()-dt$date)
  dt <- dt[,-c("date")]
  dt$year <- as.numeric(substr(Sys.Date(),1,4)) - as.numeric(as.character(dt$year))
  
  index_ <- sample(nrow(dt),replace = F)
  index_train <- index_[1:round(0.7*length(index_))]
  index_test <- index_[(round(0.7*length(index_))+1):length(index_)]
  
  dt <- data.frame(dt)[,c(4,1:3,5:ncol(dt))]
  
  trainset <- as.data.frame(dt[index_train,])
  testset <- as.data.frame(dt[index_test,])
  
  xgb_train <- data.matrix(trainset)
  xgb_test <- data.matrix(testset)
  xgb_model <- xgboost(data = xgb_train[,-1], label = xgb_train[,1], nthread = 2, nrounds = nround, 
                       early_stopping_rounds=100,
                       # objective = "reg:linear", # deprecated
                       objective = "reg:squarederror")
  
  pred_xgb_train <- unlist(predict(xgb_model,xgb_train[,-1]))
  (rmse_xgb_train <- sqrt(colMeans((as.data.frame(xgb_train[,1])-pred_xgb_train)^2)))/mean(dt$price)

  plot(pred_xgb_train, type = "p", main = "Train performance", ylab = "Training set")
  lines(xgb_train[,1], type = "p", col = "red")
  
  pred_xgb <- unlist(predict(xgb_model,xgb_test[,-1]))
  (rmse_xgb <- sqrt(colMeans((as.data.frame(xgb_test[,1])-pred_xgb)^2)))/mean(dt$price)
  
  plot(pred_xgb, type = "p", col = "red")
  lines(xgb_test[,1], type = "p", main = "Test performance", ylab = "Test set")
  
  names <- dimnames(xgb_train[,-1])[[2]]
  importance_matrix <- xgb.importance(names, model = xgb_model)
  xgb.plot.importance(importance_matrix[1:20,])
  
  xgb.save(xgb_model, fname = output_file)
}


predict_car <- function(data, year, km, color, city, brand, model, ad_date){
  xgb_model <- xgb.load(paste0(here(),'/data/xgb.model'))
  
  city <-  ifelse(city == "istanbul", "İstanbul", city)
  deploy_values <- t(data.matrix(c(as.numeric(substr(Sys.Date(),1,4)) - as.numeric(year),
                                   km, 
                                   which(levels(data$color)==str_to_title(color)), 
                                   which(levels(data$city)==str_to_title(city)), 
                                   which(levels(data$brand)==str_to_title(brand)), 
                                   which(levels(data$model)==str_to_title(model)), 
                                   as.numeric(Sys.Date()-as.Date(ad_date)))))
  
  return(predict(xgb_model,deploy_values))  
}
