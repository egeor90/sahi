options(warn=-1)
Sys.setlocale("LC_ALL", 'en_US.UTF-8')

pck_ <- c("tidyverse", "rvest", "stringr", "rebus", "lubridate", "dplyr", "here")

pck <- pck_[!(pck_ %in% installed.packages()[,"Package"])]
if(length(pck)){
  cat(paste0("Installing: ", pck, "\n"))
  install.packages(pck, repos = 'http://cran.us.r-project.org')
}


suppressWarnings(suppressMessages(invisible(lapply(pck_, require, character.only = TRUE))))

setwd(here())


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
