# Taxi Trip Price Prediction

A linear regression model built in R that predicts taxi trip prices based on fare structure, distance, duration, and contextual factors like time of day and weather.

---

## Overview

This project uses real-world taxi trip data from Kaggle to train and evaluate a predictive pricing model. The goal is to accurately estimate trip prices given a set of trip and environmental features, using interaction terms to capture how pricing components combine in practice.

---

## Dataset

- **Source:** [Kaggle](https://www.kaggle.com/) — `taxi_trip_pricing.csv`
- **Target variable:** `Trip_Price`
- **Features used:**
  - `Base_Fare`, `Per_Km_Rate`, `Per_Minute_Rate`
  - `Trip_Distance_km`, `Trip_Duration_Minutes`
  - `Time_of_Day`, `Day_of_Week`, `Traffic_Conditions`, `Weather`
  - `Passenger_Count`

---

## Methodology

### 1. Data Cleaning
- Dropped rows with missing values in key categorical columns (`Time_of_Day`, `Traffic_Conditions`, `Weather`, `Day_of_Week`, `Trip_Price`)
- Imputed remaining missing numeric values using **training set statistics only** to prevent data leakage:
  - Median imputation for skewed variables (`Trip_Distance_km`, `Passenger_Count`)
  - Mean imputation for fare-related variables
- Converted categorical variables to factors for use in the regression model

### 2. Train/Test Split
- 70/30 split using `caTools::sample.split` on the target variable
- Imputation values derived exclusively from the training set

### 3. Model
A multiple linear regression model with **interaction terms** to reflect how pricing factors compound:

```
Trip_Price ~ Base_Fare * Time_of_Day
           + Trip_Distance_km * Per_Km_Rate
           + Trip_Duration_Minutes * Per_Minute_Rate
```

### 4. Evaluation
Model performance was assessed on the held-out test set using three metrics:

| Metric | Description |
|--------|-------------|
| **10.41559** | Mean Absolute Error — average prediction error in dollars |
| **13.39343** | Root Mean Squared Error — penalizes larger errors more heavily |
| **0.8866376** | Coefficient of determination — proportion of variance explained |

---

## Visualization

A scatter plot of predicted vs. actual prices is generated, with point size scaled by absolute error, to give an intuitive view of where the model performs well and where it struggles.

<img width="1230" height="664" alt="image" src="https://github.com/user-attachments/assets/4a26898e-b0c1-4daa-9efc-5f2b942ad610" />

> *Point size reflects prediction error — smaller dots indicate more accurate predictions.*

---

## Requirements

- R (≥ 4.0)
- `tidyverse`
- `caTools`

Install dependencies:
```r
install.packages(c("tidyverse", "caTools"))
```

---

## Usage

1. Download `taxi_trip_pricing.csv` from Kaggle and place it in `~/Downloads/`
2. Open and run `Taxi_Predictions.R` in RStudio or from the terminal:
```bash
Rscript Taxi_Predictions.R
```
3. Results are saved to `Predicted Taxi Prices 2.csv`

---

## Files

```
├── Taxi_Predictions.R        # Main modeling script
├── Predicted Taxi Prices 2   # Model output (predicted vs. actual prices)
└── README.md
```

---
