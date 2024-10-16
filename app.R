library(shiny)
library(ape)
library(seqinr)

# Define UI
ui <- fluidPage(
    titlePanel("VIPER: Viral Informatics Phylogenetic Evolutionary Resource"),
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Upload DNA Sequence (FASTA)", accept = c(".fasta")),
            selectInput("method", "Choose Phylogenetic Method", choices = c("Neighbor Joining", "UPGMA")),
            actionButton("analyze", "Analyze Sequence")
        ),
        mainPanel(
            h3("Analysis Results"),
            textOutput("status"),
            plotOutput("phyloTree"),  # Consistently use "phyloTree"
            tableOutput("metrics")
        )
    )
)

# Define server logic
server <- function(input, output) {
    observeEvent(input$analyze, {
        req(input$file)

        tryCatch({
            # Read FASTA file
            fasta_file <- read.fasta(input$file$datapath)
            output$status <- renderText("File processed successfully.")

            # Perform phylogenetic analysis
            output$phyloTree <- renderPlot({
                tree <- rtree(10)  # Example: random tree generation
                plot(tree, main = "Phylogenetic Tree")
            })

            # Optionally calculate metrics and display them in a table
            output$metrics <- renderTable({
                # Replace with actual metrics computation
                data.frame(Metric = c("Seq1", "Seq2"), Value = c(0.5, 0.7))
            })
        }, error = function(e) {
            output$status <- renderText("Error processing the file: Invalid format or content.")
        })
    })
}

# Run the application
shinyApp(ui = ui, server = server)
