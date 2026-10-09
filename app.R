library(shiny)
library(apihelperR)
library(leaflet)

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

      # Two tabs: table and map
      tabsetPanel(

        tabPanel(
          "Earthquake Data",

          h3("Earthquake data"),

          tableOutput("results")
        ),

        tabPanel(
          "Earthquake Map",

          h3("Earthquake map"),

          leafletOutput(
            "earthquake_map",
            height = 600
          )
        )

      )
    )
  )
)


server <- function(input, output, session) {

  # Get earthquake data when search button is pressed
  earthquake_data <- eventReactive(input$search, {

    data <- get_earthquakes(
      start_date = as.character(input$start_date),
      end_date = as.character(input$end_date),
      min_magnitude = input$min_magnitude,
      limit = input$limit
    )

    # Convert Unix timestamp to readable UTC date and time
    data$time <- format(
      as.POSIXct(
        data$time,
        origin = "1970-01-01",
        tz = "UTC"
      ),
      format = "%Y-%m-%d %H:%M:%S"
    )

    data
  })


  # -------------------------
  # Spreadsheet/table
  # -------------------------

  output$results <- renderTable({

    earthquake_data()

  })


  # -------------------------
  # Earthquake map
  # -------------------------

  output$earthquake_map <- renderLeaflet({

    data <- earthquake_data()

    leaflet(data) |>

      # Add normal world map
      addTiles() |>

      # Plot every earthquake coordinate
      addCircleMarkers(
        lng = ~longitude,
        lat = ~latitude,

        # Larger earthquakes get larger points
        radius = ~pmax(magnitude * 1.5, 3),

        # Information shown when clicking a point
        popup = ~paste0(
          "<b>Place:</b> ", place,
          "<br>",
          "<b>Magnitude:</b> ", magnitude,
          "<br>",
          "<b>Depth:</b> ", depth, " km",
          "<br>",
          "<b>Time:</b> ", time,
          "<br>",
          "<b>Longitude:</b> ", longitude,
          "<br>",
          "<b>Latitude:</b> ", latitude
        )
      )
  })

}


shinyApp(
  ui = ui,
  server = server
)
