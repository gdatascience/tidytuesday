library(shiny)
library(tidyverse)
library(DT)
library(openxlsx)
library(bslib)

# UI layout with Superhero theme
ui <- fluidPage(
  theme = bs_theme(bootswatch = "superhero"),
  tags$head(
    tags$title("Pinewood Derby App"),  # Correct way to set browser tab title
    tags$style(HTML(".title { display: flex; justify-content: space-between; align-items: center; width: 100%; } .title img { height: 50px; }"))
  ),
  titlePanel(
    div(class = "title", 
        "Pinewood Derby App",
        img(src = "https://shacbsa.org/Data/Sites/1/media/instep/pinewood-derby/pinewood-derby.png", height = "50px")
    )
  ),
  sidebarLayout(
    sidebarPanel(
      numericInput("num_cars", "Number of Cars:", 21, min = 2),  # Input for number of cars
      numericInput("num_lanes", "Number of Lanes:", 4, min = 2),  # Input for number of lanes
      actionButton("generate", "Generate Schedule"),  # Button to generate schedule
      hr(),
      uiOutput("heat_selector"),  # Dynamic UI for selecting heats
      uiOutput("results_input"),  # Dynamic UI for entering race results
      actionButton("save_results", "Save Results"),  # Button to save results
      downloadButton("download_results", "Download Results")  # Button to download results
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Schedule", DTOutput("schedule_table")),  # Tab for displaying schedule
        tabPanel("Results", DTOutput("results_table")),  # Tab for displaying results
        tabPanel("Standings", DTOutput("standings_table"))  # Tab for displaying standings
      )
    )
  )
)

# Server logic
server <- function(input, output, session) {
  schedule_data <- reactiveVal()  # Stores race schedule
  results_data <- reactiveVal()  # Stores race results
  
  # Generate race schedule when button is clicked
  observeEvent(input$generate, {
    num_cars <- input$num_cars
    num_lanes <- input$num_lanes
    
    # Create race schedule with cars rotating through lanes
    schedule <- tibble(
      car = rep(1:num_cars, times = num_lanes),
      lane = rep(1:num_lanes, times = num_cars),
      heat = rep(1:num_cars, each = num_lanes)
    ) |> pivot_wider(
      names_from = lane,
      values_from = car,
      names_prefix = "lane_"
    )
    
    # Create results table with placeholders
    results <- tibble(
      heat = rep(1:num_cars, each = num_lanes),
      place = rep(1:num_lanes, times = num_cars),
      car = rep(NA, num_cars * num_lanes)
    ) |> pivot_wider(
      names_from = place,
      values_from = car,
      names_prefix = "place_"
    )
    
    schedule_data(schedule)  # Store schedule
    results_data(results)  # Store results
  })
  
  # Display race schedule in a table
  output$schedule_table <- renderDT({
    req(schedule_data())
    datatable(schedule_data())
  })
  
  # Display race results in a table (editable)
  output$results_table <- renderDT({
    req(results_data())
    datatable(results_data(), editable = TRUE)
  })
  
  # Generate dropdown for selecting heat
  output$heat_selector <- renderUI({
    req(results_data())
    selectInput("selected_heat", "Select Heat:", choices = unique(results_data()$heat))
  })
  
  # Generate input fields for entering results
  output$results_input <- renderUI({
    req(input$selected_heat)
    num_lanes <- input$num_lanes
    lapply(1:num_lanes, function(i) {
      numericInput(paste0("place_", i), paste("Place", i, "Car #"), value = NA, min = 1, max = input$num_cars)
    })
  })
  
  # Save entered results to the results data table
  observeEvent(input$save_results, {
    req(results_data(), input$selected_heat)
    results <- results_data()
    heat <- input$selected_heat
    
    for (i in 1:input$num_lanes) {
      col_name <- paste0("place_", i)
      results[results$heat == heat, col_name] <- input[[col_name]]
    }
    results_data(results)
  })
  
  # Calculate standings based on points (1st place = 1 point, etc.)
  standings_data <- reactive({
    req(results_data())
    results <- results_data()
    standings <- results |> 
      pivot_longer(cols = starts_with("place_"), names_to = "place", values_to = "car") |> 
      mutate(points = as.numeric(str_extract(place, "\\d+"))) |> 
      group_by(car) |> 
      summarise(total_points = sum(points, na.rm = TRUE)) |> 
      arrange(total_points)
    standings
  })
  
  # Display standings in a table
  output$standings_table <- renderDT({
    req(standings_data())
    datatable(standings_data())
  })
  
  # Enable results download as an Excel file
  output$download_results <- downloadHandler(
    filename = "pinewood_derby_results.xlsx",
    content = function(file) {
      wb <- createWorkbook()
      addWorksheet(wb, "schedule")
      addWorksheet(wb, "results")
      addWorksheet(wb, "standings")
      writeData(wb, sheet = 1, schedule_data())
      writeData(wb, sheet = 2, results_data())
      writeData(wb, sheet = 3, standings_data())
      saveWorkbook(wb, file, overwrite = TRUE)
    }
  )
}

# Run the Shiny app
shinyApp(ui, server)
