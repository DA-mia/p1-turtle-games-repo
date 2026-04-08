# Turtle Games
## Exploratory Analysis in R: Understanding Customer Behaviour and Loyalty Drivers

###############################################################################

# This section reproduces the exploratory analysis using R to ensure
# consistency across tools and support internal workflows at Turtle Games.
# The analysis focuses on understanding customer demographics,
# spending behaviour, and loyalty point accumulation using summary
# statistics and visualisations. Key patterns such as age and education
# distributions, spending behaviour, and loyalty trends are explored
# to identify meaningful behavioural insights.

###############################################################################

# 5. Exploratory analysis

    #Import the necessary libraries
    library(tidyverse)
    
    # Set your working directory
    # getwd()
    # setwd("C:/Users/...")
    
    
    # Import the data set
    df = read.csv('turtle_reviews_clean.csv')
    
    # View the data frame
    head(df)
    str(df)
    summary(df)
    
    # Plot age on a histogram (as continuous varibale)
    # ggplot(df, aes(x=age))+
    #   geom_histogram(stat='count', fill='darkgreen') +
    #   ggtitle("Distribution of Age") +
    #   scale_x_continuous(breaks = seq(min(df$age), max(df$age), by = 2))
    # Results too dispersed
    
    # Create age bins
    df$age_group <- cut(df$age, 
                        breaks = c(15, 25, 35, 45, 55, 65, 75), 
                        labels = c("15–24", "25–34", "35–44", "45–54", "55–64", "65+"), 
                        right = FALSE)
    # Check df columns
    names(df)
    
    # Calculate age bins share
    df_percent <- df %>%
      count(age_group) %>%
      mutate(percent = round(n / sum(n) * 100, 1))
    
    # Plot age bins on a histagram with lables in %
    ggplot(df_percent, aes(x = age_group, y = n)) +
      geom_bar(stat = "identity", fill = 'darkgreen') +
      geom_text(aes(label = paste0(percent, "%")), vjust = -0.5, color = "black") +
      ggtitle("Distribution of Age Groups") +
      xlab("Age Group") +
      ylab("Count") +
      coord_cartesian(ylim = c(0, max(df_percent$n) + 100))
    
    
    # Calculate gender share
    df_percent <- df %>%
      count(gender) %>%
      mutate(percent = round(n / sum(n) * 100, 1))
    
    # Plot gender on a histagram in %
    ggplot(df_percent, aes(x = gender, y = n)) +
      geom_bar(stat = "identity", fill = 'darkgreen') +
      geom_text(aes(label = paste0(percent, '%')), vjust = -0.5, colour = 'black')  +
      ggtitle("Distribution of Gender") +
      xlab("Gender") +
      ylab("Count") +
      coord_cartesian(ylim = c(0, max(df_percent$n) + 100))
    
    
    # Calculate education share
    df_percent <- df %>%
      count(education) %>%
      mutate(percent = round(n / sum(n) * 100, 1))
    
    # Plot gender on a histagram in %
    ggplot(df_percent, aes(x = education, y = n)) +
      geom_bar(stat = "identity", fill = 'darkgreen') +
      geom_text(aes(label = paste0(percent, '%')), vjust = -0.5, colour = 'black') +
      ggtitle("Distribution of Education level") +
      xlab("Education level") +
      ylab("Count") +
      coord_cartesian(ylim = c(0, max(df_percent$n) + 100))
    
    # Top sold products
    df %>%
      count(product, sort = TRUE)
    # Top 3 products sold up to 13 times, Top 4 - Top 194 sold 10 units each
    # On general, no significant product preference
    
    # Check product preference per education level
    # df %>%
    #  count(product, education) %>%
    # group_by(education) %>%
    #  mutate(share = round(n / sum(n) * 100, 1)) %>%
    #  arrange(education, desc(n))


# Explore data through visualizations (plots)

    # Plot gender and age
    ggplot(df, aes(x=age, y=gender)) +
      geom_boxplot(fill='darkgreen',
                   outlier.color='green')
    # >> females slightly younger, while males with slightly larger age range
    
    # Plot gender and loyalty
    ggplot(df, aes(x=loyalty_points, y=gender)) +
      geom_boxplot(fill='darkgreen',
                   outlier.color='green') +
      ggtitle("Loyalty points distribution per gender")
    # No significant influence of gender on loyalty
    
    # Plot loyalty_points and education
    ggplot(df, aes(x=loyalty_points, y=education)) +
      geom_boxplot(fill='darkgreen',
                   outlier.color='green') +
      ggtitle('Distribution of loyalty points per education level')
    # >> Basic education has significantly higher loyalty than other education levels
    
    
    # Calculate education and gender share
    df_edu_percent <- df %>%
      count(education, name = "total_count") %>%
      mutate(overall_percent = round(total_count / sum(total_count) * 100, 1))
    df_gender_percent <- df %>%
      count(education, gender, name = "count") %>%
      left_join(df_edu_percent, by = "education") %>%
      group_by(education) %>%
      mutate(gender_percent = round(count / sum(count) * 100, 1)) %>%
      ungroup()
    
    # View calculated gender percentage per education level
    head(df_gender_percent)
    
    # Plot distribution by education and gender as stacked bar
    ggplot(df_gender_percent, aes(x = education, y = count, fill = gender)) +
      geom_bar(stat = "identity") +
        # Gender percentage inside stacked bars
      geom_text(aes(label = paste0(gender_percent, "%")),
                position = position_stack(vjust = 0.5),
                colour = "black", size = 3) +
        # Overall education percentage on top of each bar
      geom_text(data = df_edu_percent,
                aes(x = education, y = total_count + 40, 
                    label = paste0(overall_percent, "%")),
                inherit.aes = FALSE, colour = "black", size = 4) +
        scale_fill_manual(values = c("Male" = "darkgreen", "Female" = "#6B8E23")) +
      ggtitle("Distribution by Education and Gender") +
      xlab("Education") +
      ylab("Count of customers")


# Plot loyalty points per education level

    # Summarize loyalty points by education
    df_loyalty <- df %>%
      group_by(education) %>%
      summarise(loyalty_total = sum(loyalty_points), .groups = "drop")
    
    # Calculate overall percentage share per education level
    df_edu_loyalty <- df_loyalty %>%
      mutate(overall_percent = round(loyalty_total / sum(loyalty_total) * 100, 1))
    
    # Plot *total* loyalty points per education level
    ggplot(df_loyalty, aes(x = education, y = loyalty_total)) +
      geom_bar(stat = "identity", fill = "darkgreen") +
        # Add overall education-level percentages above each bar
      geom_text(data = df_edu_loyalty,
                aes(x = education, y = loyalty_total + max(loyalty_total) * 0.05, 
                    label = paste0(overall_percent, "%")),
                inherit.aes = FALSE, colour = "darkgreen", size = 4) +
        ggtitle("Total Loyalty Points by Education Level") +
      xlab("Education") +
      ylab("Total Loyalty Points")
    # In total numbers (sum), graduate and highly educated most
    # important customer groups

    
    # Calculate *Average* Loyalty Points by Education
    df_loyalty_avg <- df %>%
      group_by(education) %>%
      summarise(avg_loyalty = round(mean(loyalty_points), 1), .groups = "drop")
    # Plot Average Loyalty Points by Education
    ggplot(df_loyalty_avg, aes(x = education, y = avg_loyalty)) +
      geom_bar(stat = "identity", fill = "darkgreen") +
      geom_text(aes(label = avg_loyalty),
                vjust = -0.4, colour = "black", size = 3) +
      ggtitle("Average Loyalty Points by Education Level") +
      xlab("Education") +
      ylab("Average Loyalty Points")
    
    # Calculate *Average* Loyalty Points by age group
    df_loyalty_avg <- df %>%
      group_by(age_group) %>%
      summarise(avg_loyalty = round(mean(loyalty_points), 1), .groups = "drop")
    # Plot Average Loyalty Points by age group
    ggplot(df_loyalty_avg, aes(x = age_group, y = avg_loyalty)) +
      geom_bar(stat = "identity", fill = "darkgreen") +
      geom_text(aes(label = avg_loyalty),
                vjust = -0.4, colour = "black", size = 2.5) +
      ggtitle("Average Loyalty Points by Age Group") +
      xlab("Age_group") +
      ylab("Average Loyalty Points")
    

#########

# Deep dive into "Basic educational level":

  # Check basic level mean and median
  df %>%
  filter(education == "Basic") %>%
  summarise(
    mean = mean(loyalty_points),
    median = median(loyalty_points),
    min = min(loyalty_points),
    Q1 = quantile(loyalty_points, 0.25),
    Q3 = quantile(loyalty_points, 0.75),
    sd = sd(loyalty_points)
  )
    # Visualize basic education level density
    ggplot(df %>% filter(education == "Basic"), aes(x = loyalty_points)) +
      geom_density(fill = "darkgreen", alpha = 0.6) +
      ggtitle("Density of Loyalty Points – Basic Education") +
      xlab("Loyalty Points") +
      ylab("Density")
    # Mean loyalty points for Basic education: ~2265
    # Median: 1622
    # Q1–Q3 range: 1177 to 3954
    # Minimum: 66
    # Density plot: Peak around 1000, dip near 3000, small bump near 4000
    # Boxplot: Slightly right-skewed, no outliers, whiskers not extreme
    # High loyalty, though only 2,5% of overall customer share (50 customers)
    
    # Filter dataset to basic level education
    df_edu_basic <- df %>%
      filter(education == "Basic")
    # Plot basic education and spending
    ggplot(df_edu_basic, aes(x = education, y = spending_score)) +
      geom_boxplot(fill = "darkgreen", outlier.color = "green") +
      ggtitle("Spending Score for Basic Education Level")
    # Plot basic education and remuneration
    ggplot(df_edu_basic, aes(x = education, y = remuneration)) +
      geom_boxplot(fill = "darkgreen", outlier.color = "green") +
      ggtitle("Spending Score for Basic Education Level")
    
    # Check descriptive stats for remuneration (filtered for basic level education)
    df_edu_basic %>%
        summarise(
        mean = mean(remuneration),
        median = median(remuneration),
        min = min(remuneration),
        Q1 = quantile(remuneration, 0.25),
        Q3 = quantile(remuneration, 0.75),
        sd = sd(remuneration))
    
    # Check count of basic education level customer in the dataset
    table(df$education)
    
    # Check characteristics for basic education level
    summary(df_edu_basic)
    table(df_edu_basic$age_group)
    # bin 25-34 = 20x, bin 45-54=30x
    
##### Check distribution for age and education
    
    # Age groups
    
    # Check loyalty distribution per age level
    ggplot(df, aes(x = age_group, y = loyalty_points)) +
      geom_boxplot() + 
      ggtitle("Loyalty distribution per age group")
    # Check "C:/Users/SasunicMiaEFS/OneDrive/LSE_DA/04_Course 3_Advanced Analytics for Organisational Impact/07_LSE_DA3_Assignment 3/LSE_DA301_assignment_files_new/R_Loyalty distribution per age group.png"
    ggplot(df, aes(x = age_group, y = spending_score)) +
      geom_boxplot() + 
      ggtitle("Spending score distribution per age group")
    # Check remuneration distribution per education level
    ggplot(df, aes(x = age_group, y = remuneration)) +
      geom_boxplot() + 
      ggtitle("Remuneration distribution per age group")
    
    # Education level
    
    # Check loyalty distribution per education level
    ggplot(df, aes(x = education, y = loyalty_points)) +
      geom_boxplot() + 
      ggtitle("Loyalty distribution per Education Level")
    
    # Check spending score distribution per education level
    ggplot(df, aes(x = education, y = spending_score)) +
      geom_boxplot() + 
      ggtitle("Spending score distribution per Education Level")
    
    # Check remuneration distribution per education level
    ggplot(df, aes(x = education, y = remuneration)) +
      geom_boxplot() + 
      ggtitle("Remuneration distribution per Education Level")
    
    # As in Jupyter Notebook, decision not to transform loyalty data
    # to ensure interpretability

######

# Plot relationship spending score and loyalty points
ggplot(df, aes(x = spending_score, y = loyalty_points)) +
  geom_point(color = "darkgreen", alpha = 0.6) +
  ggtitle("Correlation Loyalty Points vs Spending score") +
  xlab("Spending score") +
  ylab("Loyalty Points")

# Correlation remuneration vs loyalty
plot(df$remuneration , df$loyalty_points)

# Correlation age vs loyalty -> non linear relationship
plot(df$age , df$loyalty_points)

# Same results as in Jupyter Notebook:
# - age-loyalty relationship is not linear
# - spending score and remuneration scatterplots show signs of heteroscedasticity

###############################################################################
###############################################################################

# 6. Evaluating Predictors of Loyalty

# This section builds and evaluates multiple linear regression models to
# assess whether customer characteristics can reliably predict loyalty points.
# The analysis examines model fit, feature relevance, and limitations,
# and provides recommendations on how the loyalty programme and
# modelling approach could be improved. 

################################################################################

#Import the necessary libraries
library(tidyverse)

# Set your working directory

# Import the data set
df = read.csv('turtle_reviews_clean.csv')

#### Multiple linear regression

## Split dataset into training (70%) and test (30%) data
set.seed(42)
sample_index <- sample(1:nrow(df), size = 0.7 * nrow(df))
train_data <- df[sample_index, ]
test_data <- df[-sample_index, ]

## Fit model with training data (model with all variables)
    model <- lm(loyalty_points ~ remuneration + spending_score + education + age + gender, data = train_data)
    summary(model)
    
    # Predict on test data
    predictions <- predict(model, newdata = test_data)
    
    # Check goodnes of fit
    actuals <- test_data$loyalty_points
    
    # Mean Squared Error (MSE)
    mse <- mean((predictions - actuals)^2)
    
    # Root Mean Squared Error (RMSE)
    rmse <- sqrt(mse)
    
    # R-squared on test data
    sst <- sum((actuals - mean(actuals))^2)
    sse <- sum((predictions - actuals)^2)
    r_squared_test <- 1 - (sse / sst)
    
    # Print results
    cat("RMSE:", round(rmse, 2), "\n")
    cat("Test R-squared:", round(r_squared_test, 4), "\n")
    # RMSE: 530.04
    # Test r-squared: 0.8463

    
## Fit model with training data (model without education, gender and age)
    model <- lm(loyalty_points ~ remuneration + spending_score, data = train_data)
    summary(model)
    
    # Predict on test data
    predictions <- predict(model, newdata = test_data)
    
    # Check goodnes of fit
    actuals <- test_data$loyalty_points
    
    # Mean Squared Error (MSE)
    mse <- mean((predictions - actuals)^2)
    
    # Root Mean Squared Error (RMSE)
    rmse <- sqrt(mse)
    
    # R-squared on test data
    sst <- sum((actuals - mean(actuals))^2)
    sse <- sum((predictions - actuals)^2)
    r_squared_test <- 1 - (sse / sst)
    
    # Print results
    cat("RMSE:", round(rmse, 2), "\n")
    cat("Test R-squared:", round(r_squared_test, 4), "\n")
    # RMSE: 559.74
    # Test r-squared: 0.8285
    
# Check for multicolinearity
install.packages("car")

# Load the package
library(car)

# Run VIF on your model
vif(model)
# No multicollinearity

# Plot residuals
plot(model$residuals)

# Plot model
predicted <- predict(model, newdata = test_data)
actual <- test_data$loyalty_points

plot(actual, predicted,
     xlab = "Actual Loyalty Points",
     ylab = "Predicted Loyalty Points",
     main = "Predicted vs. Actual Loyalty Points",
     pch = 19, col = "blue")
abline(a = 0, b = 1, col = "red", lwd = 2)  # Ideal fit line


### Predict loyalty for a customer with known attributes

# Scenario 1: low income, low spending
new_customer <- data.frame(
  remuneration = 40,
  spending_score = 40
)
predicted_loyalty <- predict(model, newdata = new_customer)
print(predicted_loyalty)
# Result = 977.6939 

# Scenario 2: low income, average spending
new_customer <- data.frame(
  remuneration = 40,
  spending_score = 50
)
predicted_loyalty <- predict(model, newdata = new_customer)
print(predicted_loyalty)
# Result = 1300.814 

# Scenario 3: low income, high spending
new_customer <- data.frame(
  remuneration = 40,
  spending_score = 70
)
predicted_loyalty <- predict(model, newdata = new_customer)
print(predicted_loyalty)
# Result = 1947.055 

# The R model closely mirrors the Python findings:spending score is the
## strongest and most reliable predictor of loyalty, while remuneration 
## —although statistically significant— cannot be shaped by the business.
## This reinforces the conclusion that loyalty improvements should be driven
## through initiatives that increase customer spending behaviour, such as 
## bundles, cross‑sell nudges, and targeted promotional campaigns.

###############################################################################
###############################################################################




