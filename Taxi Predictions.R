# This file showcases my taxi price prediction model

# Loading packages
library(tidyverse)
library(caTools)
set.seed(123)

# Loading data
df <- read_csv("~/Downloads/taxi_trip_pricing.csv")

# Dropping rows
prep_df <- df |>
  drop_na(Time_of_Day, Traffic_Conditions, Weather, Day_of_Week, Trip_Price) |>

# Splitting into training and testing sets
  mutate(Train = sample.split(Trip_Price, SplitRatio = 0.70))
train <- prep_df |>
  filter(Train == TRUE)

test <- prep_df |>
  filter(Train == FALSE)

# Calculating values to replace N/A values
median_trip_dis <- median(train$Trip_Distance_km, na.rm = TRUE) # median because values are skewed
median_passenger <- median(train$Passenger_Count, na.rm = TRUE)
mean_base_fare <- mean(train$Base_Fare, na.rm = TRUE)
mean_per_km_rate <- mean(train$Per_Km_Rate, na.rm = TRUE)
mean_per_min_rate <- mean(train$Per_Minute_Rate, na.rm = TRUE)
mean_trip_duration <- mean(train$Trip_Duration_Minutes, na.rm = TRUE)

# Finishing cleaning by combining data and imputing above values
clean_df <- bind_rows(train, test) |>
  mutate(Trip_Distance_km = replace_na(Trip_Distance_km, median_trip_dis),
         Passenger_Count = replace_na(Passenger_Count, median_passenger),
         Base_Fare = replace_na(Base_Fare, mean_base_fare),
         Per_Km_Rate = replace_na(Per_Km_Rate, mean_per_km_rate),
         Per_Minute_Rate = replace_na(Per_Minute_Rate, mean_per_min_rate),
         Trip_Duration_Minutes = replace_na(Trip_Duration_Minutes, mean_trip_duration)) |>
  # Creating factors:
  mutate(Time_of_Day = factor(Time_of_Day),
         Day_of_Week = factor(Day_of_Week),
         Traffic_Conditions = factor(Traffic_Conditions),
         Weather = factor(Weather))

# Splitting data again
train <- clean_df |>
  filter(Train == TRUE)

test <- clean_df |>
  filter(Train == FALSE)

# Building the model
model <-
  lm(Trip_Price ~ Base_Fare * Time_of_Day + Trip_Distance_km * Per_Km_Rate +
       Trip_Duration_Minutes * Per_Minute_Rate, data = train)
summary(model)

results <- test |>
  mutate(Predicted_Price = predict(model, newdata = test),
         Error = abs(Predicted_Price - Trip_Price)) |>
  select(Trip_Price, Predicted_Price, Error)

write_csv(results, "Predicted Taxi Prices 2")

# Plot showing model accuracy
ploti <- results |>
  ggplot(aes(x = Predicted_Price, y = Trip_Price)) +
  geom_point(alpha = 0.6, color = "PINK", aes(size = Error)) +
  geom_smooth(method = lm, se = FALSE, color = "grey", linetype = "dashed") +
  theme_minimal() +
  labs(
    title = "Model Accuracy",
    subtitle = "Source: Kaggle",
    x = "Predicted Trip Price",
    y = "Actual Trip Price"
  )
ploti

# Metrics
MAE <- mean(results$Error)
RMSE <- sqrt(mean((results$Predicted_Price - results$Trip_Price)^2))
R2 <- cor(results$Predicted_Price, results$Trip_Price)^2

MAE
RMSE
R2

