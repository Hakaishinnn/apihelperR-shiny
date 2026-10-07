library(shiny)
library(apihelperR)

ui <- fluidPage(

  titlePanel("USGS Earthquake Explorer"),

  sidebarLayout(

    sidebarPanel(

      dateInput(
        "start_date",
        "Start date:",
        value = Sys.Date() - 7
      ),

      dateInput(
        "end_date",
        "End date:",
        value = Sys.Date()
      ),

      numericInput(
        "min_magnitude",
        "Minimum magnitude:",
        value = 4,
        min = 0
      ),

      numericInput(
        "limit",
        "Maximum number of results:",
        value = 100,
        min = 1
      ),

      actionButton(
        "search",
        "Get earthquakes"
      )
    ),

    mainPanel(

      h3("Earthquake data"),

      tableOutput("results")
    )
  )
)

server <- function(input, output, session) {

  earthquake_data <- eventReactive(input$search, {

    get_earthquakes(
      start_date = as.character(input$start_date),
      end_date = as.character(input$end_date),
      min_magnitude = input$min_magnitude,
      limit = input$limit
    )

  })

  output$results <- renderTable({

    earthquake_data()

  })

}

shinyApp(ui = ui, server = server)
