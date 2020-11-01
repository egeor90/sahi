start_ <- Sys.time()

pck_ <- "here"
pck <- pck_[!(pck_ %in% installed.packages()[,"Package"])]
if(length(pck)){
  cat(paste0("Installing: ", pck, "\n"))
  install.packages(pck, repos = 'http://cran.us.r-project.org')
}

suppressWarnings(suppressMessages(invisible(lapply(pck_, require, character.only = TRUE))))


setwd(here())

source("functions.R") # call the functions with functions.R file

# For regular usage on script, uncomment following lines and comment Terminal usage lines!
# brand <- "Car" # add brand
# model <- "Model" # add model


# For terminal usage on MacOS and Linux.
cat("Please enter the brand: ");
brand <- readLines("stdin",n=1);

cat("Please enter the model: ");
model <- readLines("stdin",n=1);


brand_ <- gsub("\ ", '-', brand, perl=T)
model_ <- gsub("\ ", '-', model, perl=T)

print("Please wait! This process may take several minutes.")


url <- paste0("https://www.sahibinden.com/",tolower(brand_),"-",tolower(model_),"?viewType=Classic&pagingSize=50")
html <- read_html(url)

max_page <- get_max_page(html = html)

captions <- get_captions(html)
links_ <- get_links(html)
get_yrkmcol(html)
get_price(html)
date_ <- get_date(html)
get_location(html=html)

df <- data.frame(caption = captions, 
                 link = links_, 
                 year = year_, 
                 km = km_, 
                 color = color_, 
                 price = price_, 
                 price_unit = price_unit, 
                 date = date_,
                 city = location_city,
                 district = location_district)

df$km <- as.numeric(gsub("\\.","",df$km))
df$link <- as.character(df$link)
df$caption <- as.character(df$caption)

df_ <- df

if(max_page <= 1 || length(max_page)==0){
  dt <- dplyr::data_frame(df_)
  dt <- dt[!duplicated(dt),]
}else if(max_page > 1){
  
  max_page <- ifelse(max_page >= 20, 20, max_page)
  
  for(i in 2:max_page){
    url[i] <- paste0("https://www.sahibinden.com/",tolower(brand_),"-",tolower(model_),"?viewType=Classic&pagingOffset=",50*(i-1),"&pagingSize=50")
  }
  
  url <- url[-1]
  
  for(i in 1:length(url)){
    html <- read_html(url[i])
    
    max_page <- get_max_page(html = html)
    
    captions <- get_captions(html)
    links_ <- get_links(html)
    get_yrkmcol(html)
    get_price(html)
    date_ <- get_date(html)
    get_location(html=html)
    
    df <- data.frame(caption = captions, 
                     link = links_, 
                     year = year_, 
                     km = km_, 
                     color = color_, 
                     price = price_, 
                     price_unit = price_unit, 
                     date = date_,
                     city = location_city,
                     district = location_district)
    
    df$km <- as.numeric(gsub("\\.","",df$km))
    df$link <- as.character(df$link)
    df$caption <- as.character(df$caption)
    
    if(!exists("df_")){
      df_ <- df
    }else{
      df_ <- rbind(df_, df)
    }
  }
  
  
  dt <- dplyr::data_frame(df_)
  dt <- dt[!duplicated(dt),]
}


dt_out <- as.data.frame(dt)


dt_out$brand <- ifelse(tolower(brand) == "bmw", "BMW", str_to_title(brand))
dt_out$model <- str_to_title(model)

write.table(file=paste0("data/",tolower(model_),".csv"), dt_out, sep = ";", quote = FALSE)

end_ <- Sys.time() 
time_ <- round(difftime(end_, start_, units='secs'),2)

system("clear")
cat(paste0("This process took ", time_, " seconds\n\n"))
cat(paste0("Successful! Please locate the file here:\n", getwd(),"/data/",paste0(tolower(model_),".csv\n\n")))
