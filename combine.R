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
