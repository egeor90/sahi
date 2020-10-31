start_ <- Sys.time()

setwd("...") # set your working directory
source("functions.R") # call the functions with functions.R file

# For regular usage, uncomment this and comment Terminal usage lines
# brand <- "Car" # add brand
# model <- "Model" # add model


# For terminal usage on MacOS and Linux.
cat("Please enter the brand: ");
brand <- readLines("stdin",n=1);

cat("Please enter the model: ");
model <- readLines("stdin",n=1);



url <- paste0("https://www.sahibinden.com/",tolower(brand),"-",tolower(model),"?viewType=Classic&pagingSize=50")
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


# late pages --------------------------------------------------------------

max_page <- ifelse(max_page >= 20, 20, max_page) # It can fetch maximum 1000 results.

for(i in 2:max_page){
  url[i] <- paste0("https://www.sahibinden.com/",tolower(brand),"-",tolower(model),"?viewType=Classic&pagingOffset=",50*(i-1),"&pagingSize=50")
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


dt_out <- as.data.frame(dt)

write.table(file=paste0(tolower(model),".csv"), dt_out, sep = ";", quote = FALSE)

end_ <- Sys.time() 
time_ <- round(difftime(end_, start_, units='secs'),2)

cat(paste0("This process took ", time_, " seconds\n\n"))
cat(paste0("Successful! Please locate the file here:\n", getwd(),"/",paste0(tolower(model),".csv\n")))
