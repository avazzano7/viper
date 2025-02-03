# Load necessary libraries
library(shiny)
library(seqinr)
library(ape)
library(msa)
library(ggplot2)
library(reshape2)

# Define UI
ui <- fluidPage(
    titlePanel(
        fluidRow(
            column(2,
                   img(src = "logo_no_background.png", height = "150px", width = "auto")
            ),
            column(9,
                   h1("Viral Informatics and Phylogenetic Evolutionary Resource",
                   style = "margin-top: 50px;")
            )
        )
    ),
    
    sidebarLayout(
        sidebarPanel(
            width = 3,
            tags$h4("Upload DNA Sequence"),
            fileInput("file", "Choose DNA Sequence File (FASTA)", accept = c(".fasta", ".fna")),
            actionButton("read", "Read Sequence", class = "btn-primary"),

            hr(),
            h4("Analysis Results"),
            textOutput("status"),
            tableOutput("metrics")
        ),
        mainPanel(
            width = 9,
            tabsetPanel(
                # Tab 1: Phylogenetic Tree
                tabPanel("Phylogenetic Tree",
                    fluidRow(
                        column(12, plotOutput("phylo_tree"))
                    )
                ),
                # Tab 2: Mutation Heatmap
                tabPanel("Mutation Heatmap",
                    fluidRow(
                        column(12, plotOutput("mutation_heatmap"))
                    )
                ),
                # Tab 3: Sequence Details
                tabPanel("Sequence Details",
                    textOutput("sequences")
                ),
                # Tab 4: Genotype Identification
                tabPanel("Codon Usage",
                    tableOutput("codon_usage")
                )
            )
        )
    ),

    tags$head(
        tags$style(HTML("
            .custom-title {
                margin-top: 20px;
            }
            .nav-tabs > li > a {
                color: #32CD32 !important;
            }
            .nav-tabs > li.active > a {
                background-color: #228B22 !important;
                color: white !important;
            }
            .btn-primary {
                background-color: #32CD32;
                color: white;
            }
            .sidebarPanel {
                background-color: #f8f9fa;
                padding: 20px;
            }
            .mainPanel {
                padding: 20px;
            }
            h4 {
                color: #343a40;
            }
        "))
    )
)


# Define server logic
server <- function(input, output) {
    sequences <- reactiveVal(NULL)
    phylo_tree <- reactiveVal(NULL)  # Store the phylogenetic tree
    mutation_data <- reactiveVal(NULL)

    observeEvent(input$read, {
        req(input$file)

        tryCatch({
            # Read FASTA file
            fasta_file <- read.fasta(input$file$datapath, seqtype = "DNA", as.string = TRUE)

            # Extract sequences as character strings
            seqs <- sapply(fasta_file, as.character)

            # Validate the number of sequences
            if (length(seqs) < 2) {
                stop("At least two sequences are required for analysis.")
            }

            # Store sequences in the reactive value
            sequences(seqs)

            # Output results
            output$status <- renderText("File read successfully.")
            output$sequences <- renderText(paste("Extracted Sequences:\n", paste(seqs, collapse = "\n")))

            # Calculate lengths and GC content
            lengths <- nchar(seqs)
            gc_content <- sapply(seqs, function(seq) {
                (sum(toupper(unlist(strsplit(seq, ""))) %in% c("G", "C")) / nchar(seq)) * 100
            })

            # Display lengths and GC content
            output$metrics <- renderTable({
                data.frame(Sequence = names(fasta_file), Length = lengths, GC_Content = gc_content)
            })

            # Align the sequences
            seqs_bstring <- Biostrings::DNAStringSet(seqs)
            alignment <- msa(seqs_bstring, method = "ClustalW")

            # Create distance matrix
            aligned_seqs <- as.DNAbin(alignment)
            dist_matrix <- dist.dna(aligned_seqs, model = "raw")

            # Generate phylogenic tree
            phylo_tree <- nj(dist_matrix)
            output$phylo_tree <- renderPlot({
                plot(phylo_tree)
            })

            # Calculate mutations by comparing each sequence to the first one
            reference_seq <- seqs[[1]]
            mutation_matrix <- sapply(seqs, function(seq) {
                # Compare each sequence to the reference and mark positions with mutations
                return(as.integer(strsplit(reference_seq, "")[[1]] != strsplit(seq, "")[[1]]))
            })

            # Store the mutation data
            mutation_data(mutation_matrix)

            # Plot mutation heatmap
            output$mutation_heatmap <- renderPlot({
                # Melt the mutation data into a long format for ggplot
                mutation_melted <- melt(mutation_matrix)
                colnames(mutation_melted) <- c("Position", "Sequence", "Mutation")

                # Create the heatmap plot
                ggplot(mutation_melted, aes(x = Position, y = Sequence, fill = Mutation)) +
                    geom_tile() +
                    scale_fill_gradient(low = "white", high = "red") +
                    theme_minimal() +
                    labs(title = "Mutation Heatmap", x = "Position", y = "Sequence") + 
                    theme(axis.text.x = element_text(angle = 90, hjust = 1))
            })

            all_codons <- c("AAA", "AAC", "AAG", "AAT", 
                "ACA", "ACC", "ACG", "ACT", 
                "AGA", "AGC", "AGG", "AGT", 
                "ATA", "ATC", "ATG", "ATT", 
                "CAA", "CAC", "CAG", "CAT", 
                "CCA", "CCC", "CCG", "CCT", 
                "CGA", "CGC", "CGG", "CGT", 
                "CTA", "CTC", "CTG", "CTT", 
                "GAA", "GAC", "GAG", "GAT", 
                "GCA", "GCC", "GCG", "GCT", 
                "GGA", "GGC", "GGG", "GGT", 
                "GTA", "GTC", "GTG", "GTT", 
                "TAA", "TAC", "TAG", "TAT", 
                "TCA", "TCC", "TCG", "TCT", 
                "TGA", "TGC", "TGG", "TGT", 
                "TTA", "TTC", "TTG", "TTT")


            output$codon_usage <- renderTable({
                req(sequences())  # Ensure sequences are loaded

                codon_counts <- sapply(sequences(), function(seq) {
                    # Preprocess: truncate sequence to ensure length is a multiple of 3
                    seq <- substring(seq, 1, floor(nchar(seq) / 3) * 3)

                    # Extract codons
                    codons <- substring(seq, seq(1, nchar(seq) - 2, by = 3), seq(3, nchar(seq), by = 3))
                    codons <- toupper(codons)

                    # Ensure codons are valid (only contain A, T, G, C)
                    valid_codons <- grepl("^[ATGC]{3}$", codons, ignore.case = TRUE)
                    codons <- codons[valid_codons]

                    # Count codon frequencies
                    codon_table <- table(factor(codons, levels = all_codons))

                    # Convert to proportions (%)
                    prop.table(codon_table) * 100
                })

                # Transpose for better display
                t(codon_counts)
            })


        }, error = function(e) {
            output$status <- renderText(paste("Error processing the file:", e$message))
            output$sequences <- renderText("")
            phylo_tree(NULL)  # Reset the tree in case of errors
        })
    })

    # Render the phylogenetic tree
    output$phylo_tree <- renderPlot({
        req(phylo_tree())  # Ensure tree exists before rendering
        tip_labels <- names(sequences())
        plot.phylo(phylo_tree(), main = "Phylogenetic Tree", tip.label = tip_labels, edge.width = 2)
    })
}

# Run the application
shinyApp(ui = ui, server = server)
