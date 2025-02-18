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
                   img(src = "logo_no_background.png", height = "120px", width = "auto")
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
            
            hr(),
            h4("Settings"),
            tags$label("Dark Mode:"),
            tags$input(id = "dark_mode_toggle", type = "checkbox", onchange = "toggleDarkMode()")
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
                    textOutput("sequences"),
                    tableOutput("metrics")
                ),
                # Tab 4: Codon Usage
                tabPanel("Codon Usage",
                    tableOutput("codon_usage")
                ),
                # Tab 5: Help
                tabPanel("Help",
                    fluidRow(
                        column(12,
                            h3("Application Overview"),
                            p("This tool is designed for viral informatics and phylogenetic evolutionary analysis."),

                            h3("Tab Descriptions"),
                            
                            h4("1. Phylogenetic Tree"),
                            p("This tab generates a phylogenetic tree based on the uploaded DNA sequences. The tree visually represents evolutionary relationships among the sequences."),

                            h4("2. Mutation Heatmap"),
                            p("This tab provides a heatmap visualization of mutations. It compares sequences to a reference and highlights differences, helping to identify key mutations."),

                            h4("3. Sequence Details"),
                            p("Displays the extracted DNA sequences from the uploaded file and the G-C content of each sequence."),

                            h4("4. Codon Usage"),
                            p("Analyzes and displays the codon frequency across the sequences, helping to study genetic composition and expression patterns."),

                            h3("Usage Instructions"),
                            p("1. Upload a DNA sequence file in FASTA or FNA format."),
                            p("2. Click the 'Read Sequence' button to process the file."),
                            p("3. Navigate through the tabs to analyze phylogenetics, mutations, sequence details, and more.")
                    )
                )
            )
        )
    )),

    tags$head(
        tags$style(HTML("
            /* Default (Light Mode) Styles */
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
            .gc-table {
                font-size: 10px; /* Adjust the font size as needed */
            }
            .mainPanel {
                padding: 20px;
            }
            h4 {
                color: #343a40;
            }

            /* Dark Mode Styles */
            .dark-mode {
                background-color: #121212 !important;
                color: #ffffff !important;
            }
            .dark-mode .nav-tabs > li > a {
                color: #1db954 !important;
            }
            .dark-mode .nav-tabs > li.active > a {
                background-color: #1db954 !important;
                color: white !important;
            }
            .dark-mode .btn-primary {
                background-color #1db954 !important;
                color: white;
            }
            .dark-mode .sidebarPanel {
                background-color: #1e1e1e !important;
            }
            .dark-mode .well {
                background-color: #1e1e1e !important;
                color: white !important;
            }
            .dark-mode .mainPanel {
                background-color: #181818 !important;
            }
            .dark-mode h4 {
                color: #bbbbbb !important;
            }
        ")),

        # JavaScript for Dark Mode Toggle
        tags$script(HTML("
            function toggleDarkMode() {
                var body = document.body;
                var isDark = body.classList.toggle('dark-mode');
                localStorage.setItem('dark-mode', isDark);
            }
            
            document.addEventListener('DOMContentLoaded', function() {
                if (localStorage.getItem('dark-mode') === 'true') {
                    document.body.classList.add('dark-mode');
                    document.getElementById('dark_mode_toggle').checked = true;
                }
            })
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
            }, class = "gc-table")

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
