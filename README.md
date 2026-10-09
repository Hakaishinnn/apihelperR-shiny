# apihelperR Shiny

This is a Shiny application for interactively exploring earthquake data from the USGS Earthquake API.

The application uses the `apihelperR` package to retrieve and process earthquake data.

Users can choose a date range, a minimum earthquake magnitude, and the number of results to retrieve. The app then displays the returned earthquake data on an interactive map and in other visual outputs.

## Requirements

The application uses the following R packages:

- `shiny`
- `leaflet`
- `sf`
- `rnaturalearth`
- `rnaturalearthdata`
- `apihelperR`

## Installation

Install the required packages:

```r
install.packages(c(
  "shiny",
  "leaflet",
  "sf",
  "rnaturalearth",
  "rnaturalearthdata",
  "remotes"
))
```

Install `apihelperR` from GitHub:

```r
remotes::install_github("balascode/apihelperR")
```

## Run the application locally

If you have cloned this repository and opened it in RStudio, run:

```r
shiny::runApp()
```

## Run directly from GitHub

The application can also be run directly from GitHub:

```r
shiny::runGitHub(
  repo = "apihelperR-shiny",
  username = "Hakaishinnn"
)
```

## How the application works

```text
User selects filters
        |
        v
Shiny calls apihelperR
        |
        v
apihelperR sends a request to the USGS API
        |
        v
USGS returns earthquake data
        |
        v
apihelperR cleans the response
        |
        v
Shiny displays the results
```

The Shiny application does not duplicate the USGS API request logic. That work is handled by `apihelperR`, which keeps the application code simpler and makes the package reusable outside Shiny.

## Package repository

The R package used by this application is available here:

https://github.com/balascode/apihelperR

## Authors

**Venkata Balaji Anupoju**  
LiU ID: `venan324`  
GitHub: `balascode`

**Marwan Karim**  
LiU ID: `marka671`  
GitHub: `Hakaishinnn`

Developed for:

**732A94 - Advanced Programming in R**  
Linköping University
