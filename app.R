# Load necessary libraries
library(shiny)
library(seqinr)
library(ape)
library(msa)
library(ggplot2)
library(reshape2)

# Load server and ui
source("R/server.R")
source("R/ui.R")

# Run the application
shinyApp(ui = ui, server = server)
