# Load required libraries
library(caret)
library(e1071)
library(tidyverse)
library(shiny)
library(pROC)
library(shinythemes)
library(randomForest)
library(plotly)
library(DT)
library(shinydashboard)
library(corrplot)
library(reshape2)  # For melt function

# Load dataset
heart <- read.csv("C:\\Users\\naman\\Downloads\\heart.csv")

# Convert target to factor
heart$target <- as.factor(heart$target)

# Create control using a logistic regression model
control <- rfeControl(functions = lrFuncs, method = "cv", number = 10)

# Run RFE to select top 10 features
set.seed(123)
rfe_result <- rfe(
  x = heart[, -which(names(heart) == "target")],
  y = heart$target,
  sizes = 1:10,
  rfeControl = control
)

# Get selected features
selected_features <- predictors(rfe_result)

# Subset the dataset using selected features
heart_selected <- heart[, c(selected_features, "target")]

# Train-test split
set.seed(42)
split <- createDataPartition(heart_selected$target, p = 0.8, list = FALSE)
train_data <- heart_selected[split, ]
test_data <- heart_selected[-split, ]

# Train logistic regression model
logit_model <- train(target ~ ., data = train_data, method = "glm", family = "binomial")

# Train random forest model
rf_model <- train(target ~ ., data = train_data, method = "rf")

# Predict on test set for both models
logit_predictions <- predict(logit_model, test_data)
rf_predictions <- predict(rf_model, test_data)

# Evaluate logistic regression performance
logit_conf_matrix <- confusionMatrix(logit_predictions, test_data$target)
logit_precision <- logit_conf_matrix$byClass["Pos Pred Value"]
logit_recall <- logit_conf_matrix$byClass["Sensitivity"]
logit_f1 <- 2 * (logit_precision * logit_recall) / (logit_precision + logit_recall)
logit_acc <- logit_conf_matrix$overall["Accuracy"]

# Evaluate random forest performance
rf_conf_matrix <- confusionMatrix(rf_predictions, test_data$target)
rf_precision <- rf_conf_matrix$byClass["Pos Pred Value"]
rf_recall <- rf_conf_matrix$byClass["Sensitivity"]
rf_f1 <- 2 * (rf_precision * rf_recall) / (rf_precision + rf_recall)
rf_acc <- rf_conf_matrix$overall["Accuracy"]

# Get ROC and AUC for logistic regression
logit_probs <- predict(logit_model, test_data, type = "prob")
logit_roc <- roc(test_data$target, logit_probs[, "1"])
logit_auc <- auc(logit_roc)

# Get ROC and AUC for random forest
rf_probs <- predict(rf_model, test_data, type = "prob")
rf_roc <- roc(test_data$target, rf_probs[, "1"])
rf_auc <- auc(rf_roc)

# Prepare for Shiny app
model_comparison <- data.frame(
  Metric = c("Accuracy", "Precision", "Recall", "F1 Score", "AUC"),
  `Logistic Regression` = c(logit_acc, logit_precision, logit_recall, logit_f1, logit_auc),
  `Random Forest` = c(rf_acc, rf_precision, rf_recall, rf_f1, rf_auc)
)

# Prepare for visualization
heart$target_factor <- factor(heart$target, levels = c("0", "1"), labels = c("No Disease", "Disease"))

# UI
ui <- dashboardPage(
  skin = "blue",
  
  # Header
  dashboardHeader(title = "Heart Disease Prediction"),
  
  # Sidebar
  dashboardSidebar(
    sidebarMenu(
      menuItem("Prediction", tabName = "prediction", icon = icon("heartbeat")),
      menuItem("Visualizations", tabName = "visualizations", icon = icon("chart-bar")),
      menuItem("Model Comparison", tabName = "model_comparison", icon = icon("chart-line"))
    )
  ),
  
  # Body
  dashboardBody(
    tabItems(
      # Prediction Tab
      tabItem(
        tabName = "prediction",
        fluidRow(
          box(
            title = "Enter Health Parameters", width = 6, status = "primary",
            selectInput("cp", "Chest Pain Type", choices = c("Typical Angina" = 0, "Atypical Angina" = 1, "Non-anginal Pain" = 2, "Asymptomatic" = 3)),
            numericInput("ca", "Major Vessels Colored (0-3)", value = 0, min = 0, max = 3),
            selectInput("sex", "Sex", choices = c("Male" = 1, "Female" = 0)),
            selectInput("thal", "Thalassemia", choices = c("Normal" = 1, "Fixed Defect" = 2, "Reversible Defect" = 3)),
            numericInput("oldpeak", "ST Depression (Oldpeak)", value = 1.0, min = 0),
            selectInput("exang", "Exercise Induced Angina", choices = c("Yes" = 1, "No" = 0)),
            numericInput("thalach", "Max Heart Rate Achieved", value = 150, min = 60, max = 220),
            numericInput("trestbps", "Resting Blood Pressure", value = 120, min = 80, max = 200),
            selectInput("slope", "Slope of ST", choices = c("Upsloping" = 0, "Flat" = 1, "Downsloping" = 2)),
            numericInput("chol", "Cholesterol", value = 200, min = 100, max = 600),
            radioButtons("model_choice", "Choose Model:", 
                         choices = c("Logistic Regression", "Random Forest"),
                         selected = "Random Forest"),
            actionButton("predictBtn", "Predict", class = "btn btn-primary btn-lg")
          ),
          box(
            title = "Prediction Result", width = 6, status = "primary",
            uiOutput("predictionBox"),
            plotlyOutput("featureImportancePlot", height = "300px")
          )
        )
      ),
      
      # Visualizations Tab
      tabItem(
        tabName = "visualizations",
        fluidRow(
          box(
            title = "Distribution of Heart Disease", width = 6, status = "info",
            plotlyOutput("targetDistPlot")
          ),
          box(
            title = "Correlation Heatmap", width = 6, status = "info",
            plotlyOutput("correlationPlot")
          )
        ),
        fluidRow(
          box(
            title = "Numeric Features by Heart Disease", width = 12, status = "info",
            selectInput("numericFeature", "Select Feature:",
                        choices = c("Age" = "age", "Cholesterol" = "chol", 
                                    "Max Heart Rate" = "thalach", "ST Depression" = "oldpeak",
                                    "Resting Blood Pressure" = "trestbps")),
            plotlyOutput("numericFeaturePlot")
          )
        )
      ),
      
      # Model Comparison Tab - REMOVED FEATURE IMPORTANCE
      tabItem(
        tabName = "model_comparison",
        fluidRow(
          box(
            title = "Model Performance Comparison", width = 12, status = "success",
            DT::dataTableOutput("comparisonTable")
          )
        ),
        fluidRow(
          box(
            title = "ROC Curves", width = 6, status = "success",
            plotlyOutput("rocCurvePlot")
          ),
          box(
            title = "Performance Metrics", width = 6, status = "success",
            plotlyOutput("metricComparisonPlot")
          )
        )
      )
    )
  )
)

# Server
server <- function(input, output) {
  # Prediction logic
  observeEvent(input$predictBtn, {
    # Collect input data based on selected features
    input_data <- data.frame(
      cp = as.numeric(input$cp),
      ca = input$ca,
      sex = as.numeric(input$sex),
      thal = as.numeric(input$thal),
      oldpeak = input$oldpeak,
      exang = as.numeric(input$exang),
      thalach = input$thalach,
      trestbps = input$trestbps,
      slope = as.numeric(input$slope),
      chol = input$chol
    )
    
    # Choose model based on user selection
    selected_model <- if(input$model_choice == "Logistic Regression") logit_model else rf_model
    
    # Predict using selected model
    prob <- predict(selected_model, newdata = input_data, type = "prob")[, "1"]
    prediction <- ifelse(prob > 0.5, 1, 0)
    
    # Display prediction result
    output$predictionBox <- renderUI({
      if (prediction == 1) {
        div(
          style = "padding: 20px; border-radius: 10px; font-size: 18px; font-weight: bold; text-align: center; background-color: #ffdddd; color: #a94442; border: 2px solid #a94442;",
          HTML(paste0("🚨 <b>The person <u>has</u> heart disease.</b><br>",
                      "Probability: ", round(prob * 100, 1), "%"))
        )
      } else {
        div(
          style = "padding: 20px; border-radius: 10px; font-size: 18px; font-weight: bold; text-align: center; background-color: #ddffdd; color: #3c763d; border: 2px solid #3c763d;",
          HTML(paste0("✅ <b>The person <u>does not have</u> heart disease.</b><br>",
                      "Probability: ", round(prob * 100, 1), "%"))
        )
      }
    })
    
    # Feature importance plot for the prediction
    output$featureImportancePlot <- renderPlotly({
      if(input$model_choice == "Random Forest") {
        imp <- varImp(rf_model)$importance
        imp_df <- data.frame(
          Feature = rownames(imp),
          Importance = imp$Overall
        )
        imp_df <- imp_df[order(imp_df$Importance, decreasing = TRUE), ]
        
        p <- plot_ly(imp_df, x = ~reorder(Feature, Importance), y = ~Importance, type = "bar",
                     marker = list(color = "#2C3E50")) %>%
          layout(title = "Feature Importance (Random Forest)",
                 xaxis = list(title = ""),
                 yaxis = list(title = "Importance"))
      } else {
        # For logistic regression, use absolute coefficient values
        coefs <- coef(logit_model$finalModel)[-1]  # Remove intercept
        imp_df <- data.frame(
          Feature = names(coefs),
          Importance = abs(coefs)
        )
        imp_df <- imp_df[order(imp_df$Importance, decreasing = TRUE), ]
        
        p <- plot_ly(imp_df, x = ~reorder(Feature, Importance), y = ~Importance, type = "bar",
                     marker = list(color = "#2C3E50")) %>%
          layout(title = "Feature Importance (Logistic Regression)",
                 xaxis = list(title = ""),
                 yaxis = list(title = "Absolute Coefficient Value"))
      }
      return(p)
    })
  })
  
  # Model comparison table
  output$comparisonTable <- DT::renderDataTable({
    DT::datatable(model_comparison, 
                  options = list(pageLength = 5, dom = 't'),
                  rownames = FALSE)
  })
  
  # ROC curve plot
  output$rocCurvePlot <- renderPlotly({
    # Prepare data for ROC curves
    logit_roc_df <- data.frame(
      FPR = 1 - logit_roc$specificities,
      TPR = logit_roc$sensitivities,
      Model = "Logistic Regression"
    )
    
    rf_roc_df <- data.frame(
      FPR = 1 - rf_roc$specificities,
      TPR = rf_roc$sensitivities,
      Model = "Random Forest"
    )
    
    roc_df <- rbind(logit_roc_df, rf_roc_df)
    
    # Create ROC curve plot
    p <- plot_ly() %>%
      add_trace(
        data = logit_roc_df,
        x = ~FPR,
        y = ~TPR,
        type = "scatter",
        mode = "lines",
        line = list(color = "#E74C3C", width = 2),
        name = paste0("Logistic Regression (AUC = ", round(logit_auc, 3), ")")
      ) %>%
      add_trace(
        data = rf_roc_df,
        x = ~FPR,
        y = ~TPR,
        type = "scatter",
        mode = "lines",
        line = list(color = "#2ECC71", width = 2),
        name = paste0("Random Forest (AUC = ", round(rf_auc, 3), ")")
      ) %>%
      add_trace(
        x = c(0, 1),
        y = c(0, 1),
        type = "scatter",
        mode = "lines",
        line = list(color = "gray", width = 1, dash = "dash"),
        name = "Random Guess"
      ) %>%
      layout(
        title = "ROC Curves Comparison",
        xaxis = list(title = "False Positive Rate"),
        yaxis = list(title = "True Positive Rate"),
        legend = list(orientation = "h", y = -0.2)
      )
    
    return(p)
  })
  
  # Performance metrics comparison plot
  output$metricComparisonPlot <- renderPlotly({
    # Prepare data for metrics comparison
    metrics_df <- data.frame(
      Metric = c("Accuracy", "Precision", "Recall", "F1 Score"),
      Logistic_Regression = c(logit_acc, logit_precision, logit_recall, logit_f1),
      Random_Forest = c(rf_acc, rf_precision, rf_recall, rf_f1)
    )
    
    # Reshape for plotting
    metrics_long <- tidyr::pivot_longer(
      metrics_df, 
      cols = c("Logistic_Regression", "Random_Forest"),
      names_to = "Model",
      values_to = "Value"
    )
    
    # Create metrics comparison plot
    p <- plot_ly(metrics_long, x = ~Metric, y = ~Value, color = ~Model, type = "bar",
                 colors = c("#E74C3C", "#2ECC71")) %>%
      layout(
        title = "Performance Metrics Comparison",
        xaxis = list(title = ""),
        yaxis = list(title = "Score", range = c(0, 1)),
        barmode = "group",
        legend = list(orientation = "h", y = -0.2)
      )
    
    return(p)
  })
  
  # Target distribution plot
  output$targetDistPlot <- renderPlotly({
    # Count target variable distribution
    target_counts <- heart %>%
      count(target_factor) %>%
      mutate(percentage = n / sum(n) * 100)
    
    # Create target distribution plot
    p <- plot_ly(target_counts, labels = ~target_factor, values = ~n, type = "pie",
                 marker = list(colors = c("#3498DB", "#E74C3C")),
                 textinfo = "label+percent",
                 insidetextorientation = "radial") %>%
      layout(title = "Heart Disease Distribution")
    
    return(p)
  })
  
  # Correlation heatmap
  output$correlationPlot <- renderPlotly({
    # Create a numeric subset of the data (excluding target)
    numeric_heart <- heart[, sapply(heart, is.numeric)]
    numeric_heart$target <- NULL  # Remove target column if present
    
    # Calculate correlation matrix
    cor_mat <- cor(numeric_heart)
    
    # Melt the correlation matrix for plotting
    melted_cor <- reshape2::melt(cor_mat)
    
    # Create heatmap
    p <- plot_ly(
      data = melted_cor,
      x = ~Var1,
      y = ~Var2,
      z = ~value,
      type = "heatmap",
      colors = colorRamp(c("#67001F", "#B2182B", "#D6604D", "#F4A582", 
                           "#FDDBC7", "#FFFFFF", "#D1E5F0", "#92C5DE", 
                           "#4393C3", "#2166AC", "#053061")),
      zmin = -1,
      zmax = 1
    ) %>%
      layout(
        title = "Feature Correlation Heatmap",
        xaxis = list(title = ""),
        yaxis = list(title = "")
      )
    
    return(p)
  })
  
  # Numeric feature plot
  output$numericFeaturePlot <- renderPlotly({
    # Get selected numeric feature
    selected_feature <- input$numericFeature
    
    # Create box plot
    p <- plot_ly() %>%
      add_boxplot(
        data = subset(heart, target == 0),
        y = ~get(selected_feature),
        name = "No Disease",
        marker = list(color = "#3498DB"),
        boxpoints = "suspectedoutliers"
      ) %>%
      add_boxplot(
        data = subset(heart, target == 1),
        y = ~get(selected_feature),
        name = "Disease",
        marker = list(color = "#E74C3C"),
        boxpoints = "suspectedoutliers"
      ) %>%
      layout(
        title = paste(selected_feature, "by Heart Disease"),
        xaxis = list(title = ""),
        yaxis = list(title = selected_feature),
        boxmode = "group"
      )
    
    return(p)
  })
}

# Run the app
shinyApp(ui = ui, server = server)