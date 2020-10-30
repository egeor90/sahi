# modelowania -------------------------------------------------------------
Sys.setlocale("LC_ALL", 'en_US.UTF-8')
require(data.table)
setwd("/Users/Ege/Google Drive/ABROAD/University of Warsaw/Free Works/nieruch/sahibinden")

dt <- data.table(read.csv("accord.csv",
                          fill=TRUE, 
                          header=TRUE, 
                          quote="", 
                          sep=";", 
                          stringsAsFactors = FALSE, 
                          encoding="UTF-8"))

dt$caption <- as.character(dt$caption)
dt$link <- as.character(dt$link)
dt$year <- as.factor(dt$year)
dt$km <- as.numeric(dt$km)
dt$color <- as.factor(dt$color)
dt$price <- as.numeric(dt$price)
dt$price_unit <- as.factor(dt$price_unit)
dt$date <- as.Date(dt$date)
dt$city <- as.factor(dt$city)
dt$district <- as.factor(dt$district)

dt <- na.omit(dt)
# colnames(dt) <- gsub("\\.","",gsub("X.","",colnames(dt)))
ege <- dt[,-c(1,2,7,10)]
ege <- ege[which(ege$km >= 1000),]
ege <- ege[which(as.numeric(as.character(ege$year)) >= 2000),]


ege$old <- as.numeric(Sys.Date()-ege$date)
ege <- ege[,-c("date")]
ege$year <- as.numeric(substr(Sys.Date(),1,4)) - as.numeric(as.character(ege$year))

model_lm <- lm(price ~ year + km + color + city + old, data = ege)
summary(model_lm)

plot(predict(lm(price ~ year + km, data = ege)), col = "red")
lines(ege$price, type = "o", lty = 0)

sqrt(mean((ege$price - predict(lm(price ~ year + km, data = ege)))**2))

ege_pred_df <- data.frame(actual = ege$price, pred = predict(lm(price ~ year + km, data = ege)))
ege_pred_df$error <- ege_pred_df$actual-ege_pred_df$pred

ege_pred_df <- ege_pred_df[order(ege_pred_df$error),]

best_car <- dt[as.numeric(rownames(ege_pred_df))[1],]
worst_car <- dt[as.numeric(rownames(ege_pred_df))[nrow(ege_pred_df)],]

best_car_link <- best_car[,"link"]
worst_car_link <- worst_car[,"link"]
exact_pred_link <- dt[which.min(abs(ege_pred_df$error)),"link"]



# dummies -----------------------------------------------------------------

require(dummies)
ege_dummies <- cbind(ege[,-c(3,5)],dummy(ege$color), dummy(ege$city))
model_lm <- lm(price ~ ., data = ege_dummies)

coefs_ <- names(which(summary(model_lm)$coefficients[,4] <= 0.1))
coefs_ <- paste("price ~ ",paste(coefs_[-1], collapse = " + "))

model_lm2 <- lm(as.formula(coefs_), data = ege_dummies)
summary(model_lm2)

coefs_ <- names(which(summary(model_lm2)$coefficients[,4] <= 0.1))
coefs_ <- paste("price ~ ",paste(coefs_[-1], collapse = " + "))

model_lm3 <- lm(as.formula(coefs_), data = ege_dummies)
summary(model_lm3)

coefs_ <- names(which(summary(model_lm3)$coefficients[,4] <= 0.05))
coefs_ <- paste("price ~ ",paste(coefs_[-1], collapse = " + "))

model_lm_fin <- lm(as.formula(coefs_), data = ege_dummies)
summary(model_lm_fin)

plot(predict(model_lm_fin), col = "red")
lines(ege$price, type = "o", lty = 0)

sqrt(mean((ege$price - predict(model_lm_fin))**2))

ege_pred_df <- data.frame(actual = ege$price, pred = predict(model_lm_fin))
ege_pred_df$error <- ege_pred_df$actual-ege_pred_df$pred

ege_pred_df <- ege_pred_df[order(ege_pred_df$error),]

dt_2 <- dt[which(dt$km >= 1000),]
dt_2 <- dt[which(as.numeric(as.character(dt$year)) >= 2000),]

best_car <- dt_2[as.numeric(rownames(ege_pred_df))[1],]
worst_car <- dt_2[as.numeric(rownames(ege_pred_df))[nrow(ege_pred_df)],]

best_car_link <- best_car[,"link"]
worst_car_link <- worst_car[,"link"]
exact_pred_link <- dt_2[which.min(abs(ege_pred_df$error)),"link"]



# xgboost -----------------------------------------------------------------

require(xgboost)

index_ <- sample(nrow(ege_dummies),replace = F)
index_train <- index_[1:round(0.7*length(index_))]
index_test <- index_[(round(0.7*length(index_))+1):length(index_)]

ege_dummies <- data.frame(ege_dummies)[,c(3,1,2,4:ncol(ege_dummies))]
trainset <- as.data.frame(ege_dummies[index_train,])
testset <- as.data.frame(ege_dummies[index_test,])

xgb_train <- data.matrix(trainset)
xgb_test <- data.matrix(testset)
xgb_model <- xgboost(data = xgb_train[,-1], label = xgb_train[,1], nthread = 2, nrounds = 1500, 
                     early_stopping_rounds=50,
                     objective = "reg:linear")
# param <- list(objective = 'reg:logistic', eval_metric = 'auc', subsample = 0.5, nthread = 4,
#               max_bin = 64, tree_method = 'gpu_hist')
# pt <- proc.time()
# bst_gpu <- xgb.train(param, dtrain, watchlist = wl, nrounds = 50)
pred_xgb_train <- unlist(predict(xgb_model,xgb_train[,-1]))
(rmse_xgb_train <- sqrt(colMeans((as.data.frame(xgb_train[,1])-pred_xgb_train)^2)))
plot(pred_xgb_train, type = "p", main = "Train performance", ylab = "Training set")
lines(pred_xgb_train, type = "p", col = "red")


pred_xgb <- unlist(predict(xgb_model,xgb_test[,-1]))
(rmse_xgb <- sqrt(colMeans((as.data.frame(xgb_test[,1])-pred_xgb)^2)))

plot(pred_xgb, type = "p", col = "red")
lines(xgb_test[,1], type = "p", main = "Test performance", ylab = "Test set")

names <- dimnames(xgb_train[,-1])[[2]]
importance_matrix <- xgb.importance(names, model = xgb_model)
xgb.plot.importance(importance_matrix[1:20,])



if(!exists("pred_values")){
      pred_values <- t(data.matrix(c(2013, 100000, 1, 0,
                                   0,0,0,0,0,
                                   0,0,0,1,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   1,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0)))
  
}else{
  for(i in 2:30){
  pred_values <- rbind(pred_values, t(data.matrix(c(2013, 100000, i, 0,
                                                    0,0,0,0,0,
                                                    0,0,0,1,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    1,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0,0,
                                                    0,0,0,0))))
  }
}


colnames(pred_values) <- colnames(xgb_test)[-1]

plot(predict(xgb_model,pred_values), type = "l", col = "red", ylab = "Price", xlab = "Days", main = "Price reaction for Renault Laguna")
