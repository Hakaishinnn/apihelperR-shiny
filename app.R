library(shiny)
library(apihelperR)
library(leaflet)
library(sf)
library(rnaturalearth)

# Turn off s2 to avoid geometry errors
sf::sf_use_s2(FALSE)

# Load country boundaries
world <- ne_countries(
  scale = "small",
  returnclass = "sf"
)

# Fix any invalid country shapes
world <- st_make_valid(world)


ui <- fluidPage(

  # Move Leaflet zoom buttons to the top-right
  tags$head(
    tags$style(HTML("
      .leaflet-top.leaflet-left {
        left: auto;
        right: 0;
      }
    "))
  ),

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

      tabsetPanel(

        tabPanel(
          "Earthquake Data",

          h3("Earthquake data"),

          tableOutput("results")
        ),

        tabPanel(
          "Earthquake Map",

          h3("Earthquake map"),

          selectInput(
            "country",
            "Choose country:",
            choices = "All countries"
          ),

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

  # Show the world map when the app starts
  output$earthquake_map <- renderLeaflet({

    leaflet() |>
      addTiles() |>
      setView(
        lng = 0,
        lat = 20,
        zoom = 2
      )
  })


  # Get earthquake data after pressing the button
  earthquake_data <- eventReactive(input$search, {

    data <- get_earthquakes(
      start_date = as.character(input$start_date),
      end_date = as.character(input$end_date),
      min_magnitude = input$min_magnitude,
      limit = input$limit
    )

    # Make the timestamp easier to read
    data$time <- format(
      as.POSIXct(
        data$time,
        origin = "1970-01-01",
        tz = "UTC"
      ),
      format = "%Y-%m-%d %H:%M:%S"
    )

    # Turn the coordinates into map points
    points <- st_as_sf(
      data,
      coords = c("longitude", "latitude"),
      crs = 4326,
      remove = FALSE
    )

    # Find which country each earthquake belongs to
    points <- st_join(
      points,
      world[, "admin"],
      left = TRUE
    )

    data <- st_drop_geometry(points)

    names(data)[names(data) == "admin"] <- "country"

    # Some earthquakes are outside country borders
    data$country[is.na(data$country)] <- "Other / Ocean"

    data
  })


  # Update the country list
  observeEvent(earthquake_data(), {

    data <- earthquake_data()

    countries <- sort(
      unique(data$country)
    )

    updateSelectInput(
      session,
      "country",
      choices = c(
        "All countries",
        countries
      ),
      selected = "All countries"
    )
  })


  # Show the earthquake table
  output$results <- renderTable({

    data <- earthquake_data()

    data[
      ,
      c(
        "id",
        "time",
        "magnitude",
        "place",
        "longitude",
        "latitude",
        "depth",
        "tsunami"
      )
    ]
  })


  # Filter the map by country
  map_data <- reactive({

    data <- earthquake_data()

    if (input$country != "All countries") {

      data <- data[
        data$country == input$country,
      ]
    }

    data
  })


  # Add earthquake points to the map
  observeEvent(
    list(earthquake_data(), input$country),
    {

      data <- map_data()

      map <- leafletProxy("earthquake_map") |>
        clearMarkers()

      if (nrow(data) > 0) {

        map <- map |>
          addCircleMarkers(
            lng = data$longitude,
            lat = data$latitude,

            radius = pmax(
              data$magnitude * 1.5,
              3
            ),

            popup = paste0(
              "<b>Place:</b> ", data$place,
              "<br>",
              "<b>Country:</b> ", data$country,
              "<br>",
              "<b>Magnitude:</b> ", data$magnitude,
              "<br>",
              "<b>Depth:</b> ", data$depth, " km",
              "<br>",
              "<b>Time:</b> ", data$time,
              "<br>",
              "<b>Longitude:</b> ", data$longitude,
              "<br>",
              "<b>Latitude:</b> ", data$latitude
            )
          )

        # Zoom in when a country is selected
        if (input$country != "All countries") {

          if (nrow(data) == 1) {

            map |>
              setView(
                lng = data$longitude[1],
                lat = data$latitude[1],
                zoom = 5
              )

          } else {

            map |>
              fitBounds(
                lng1 = min(data$longitude),
                lat1 = min(data$latitude),
                lng2 = max(data$longitude),
                lat2 = max(data$latitude)
              )
          }
        }
      }
    }
  )
}


shinyApp(
  ui = ui,
  server = server
)
