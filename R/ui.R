# Define UI
ui <- fluidPage(
    titlePanel(
    fluidRow(
        column(2,
            img(src = "logo_no_background.png", height = "120px", style = "margin-top: 10px;")
        ),
        column(10,
            tags$div(
                style = "
                margin-top: 30px;
                font-size: 32px;
                font-weight: bold;
                color: #228B22;
                letter-spacing: 1px;
                font-family: 'Segoe UI', sans-serif;
                ",
                "Viral Informatics and Phylogenetic Evolutionary Resource"
            )
        )
    )
    ),
    

    sidebarLayout(
        sidebarPanel(
            width = 3,
            style = "background-color: #f8f9fa; padding: 20px; border-radius: 10px; box-shadow: 2px 2px 6px rgba(0,0,0,0.05);",

            # Section 1: Upload
            tags$h4(icon("dna"), " Upload Viral Sequences"),
            fileInput("file", label = NULL, accept = c(".fasta", ".fna")),
            actionButton("read", "Read Sequence", class = "btn btn-success", style = "width: 100%; margin-bottom: 15px;"),

            # Divider
            tags$hr(),

            # Section 2: Status / Analysis
            tags$h4(icon("chart-line"), " Analysis Status"),
            tags$div(
                style = "margin-bottom: 10px; color: #2F7273;",
                textOutput("status")
            ),
            tags$div(
                style = "color: #555;",
                textOutput("estimated_time")
            ),

            # Divider
            tags$hr(),

            # Section 3: Settings
            tags$h4(icon("sliders-h"), " Settings"),
            div(
                style = "display: flex; align-items: center; gap: 10px;",
                tags$label("Dark Mode:"),
                tags$input(id = "dark_mode_toggle", type = "checkbox", onchange = "toggleDarkMode()")
            )
        ),
        mainPanel(
            width = 9,
            tabsetPanel(
                # Tab 0: Summary
                tabPanel("Summary",
                    fluidRow(
                        column(12, h3("Sequence Summary")),
                        column(12, wellPanel(
                            uiOutput("summary_ui")
                        ))
                    )
                ),
                # Tab 1: Phylogenetic Tree
                tabPanel("Phylogenetic Tree",
                    fluidRow(
                        column(12, h3("Phylogenetic Tree")),
                        column(12, wellPanel(
                            plotOutput("phylo_tree")
                        ))
                    )
                ),
                # Tab 2: Mutation Heatmap
                tabPanel("Mutation Heatmap",
                    fluidRow(
                        column(12, h3("Mutation Heatmap")),
                        column(12, wellPanel(
                            plotOutput("mutation_heatmap")
                        ))
                    )
                ),
                # Tab 3: Sequence Details
                tabPanel("Sequence Details",
                    fluidRow(
                        column(12, h3("Extracted DNA Sequences")),
                        column(12, wellPanel(
                            verbatimTextOutput("sequences")
                        ))
                    ),
                    hr(),
                    fluidRow(
                        column(12, h3("Sequence Metrics")),
                        column(12, wellPanel(
                            tableOutput("metrics")
                        ))
                    )
                ),
                # Tab 4: Codon Usage
                tabPanel("Codon Usage",
                    fluidRow(
                        column(12,
                        h3("Codon Usage Percentages"),
                        wellPanel(
                            div(style = "overflow-x: auto;",
                            tableOutput("codon_usage")
                            )
                        )
                        )
                    )
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

    tags$footer(
        style = "text-align: center; margin-top: 40px; color: #888;",
        "VIPER • © 2024"
    ),


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
