# apihelperR Shiny

A simple Shiny application for exploring earthquake data from the USGS Earthquake API.

The application uses the `apihelperR` package to retrieve earthquake data based on:

- Start date
- End date
- Minimum magnitude
- Maximum number of results

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
