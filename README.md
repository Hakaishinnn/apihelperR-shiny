# apihelperR Shiny

A simple Shiny application for exploring earthquake data from the USGS Earthquake API.

The application uses the `apihelperR` package to retrieve earthquake data based on:

- Start date
- End date
- Minimum magnitude
- Maximum number of results

The application also includes:

- A table of earthquake results
- An interactive world map
- Earthquake markers based on longitude and latitude
- Country filtering for the map
- Automatic zoom when a country is selected

## Installation

Install the required packages:

```r
install.packages(c(
  "shiny",
  "leaflet",
  "sf",
  "rnaturalearth",
  "rnaturalearthdata",
  "pak"
))

pak::pak("balascode/apihelperR")
