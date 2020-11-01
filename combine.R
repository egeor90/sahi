# Combine all csv files.

options(warn=-1)
Sys.setlocale("LC_ALL", 'en_US.UTF-8')

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
