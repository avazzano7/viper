# Define UI
ui <- fluidPage(
    titlePanel(
    fluidRow(
        column(10,
            tags$div(class = "viper-title",
                span("VIPER", class = "viper-brand"),
                br(),
                span("Viral Informatics and Phylogenetic Evolutionary Resource", class = "viper-subtitle")
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
            actionButton("read", "Read Sequence", class = "btn-primary", style = "width: 100%; margin-bottom: 15px;"),

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
            ),
            div(
                style = "display: flex; align-items: center; gap: 10px; margin-top: 10px;",
                tags$label("Blue Mode:"),
                tags$input(id = "blue_mode_toggle", type = "checkbox", onchange = "toggleBlueMode()")
            )
        ),
        mainPanel(
            width = 9,
            tabsetPanel(
                id = "main_tabs",          # For tab control from server
                selected = "Splash",       # Start on the splash screen tab

                # 🔹 Splash Tab (displays gif)
                tabPanel("Splash",
                    fluidPage(
                        tags$head(
                            tags$style(HTML("
                                #splash_container {
                                    display: flex;
                                    justify-content: center;
                                    align-items: center;
                                    height: 80vh;
                                    background-color: rgba(18, 18, 18, 0);
                                }

                                video {
                                    max-width: 80%;
                                    border-radius: 12px;
                                    display: none;
                                }

                                /* Default: Dark Mode, No Blue */
                                body.dark-mode:not(.blue-mode) #splash_dark {
                                    display: block;
                                }

                                /* Light Mode, No Blue */
                                body:not(.dark-mode):not(.blue-mode) #splash_light {
                                    display: block;
                                }

                                /* Dark Mode + Blue Mode */
                                body.dark-mode.blue-mode #splash_dark_blue {
                                    display: block;
                                }

                                /* Light Mode + Blue Mode */
                                body:not(.dark-mode).blue-mode #splash_light_blue {
                                    display: block;
                                }
                            "))
                        ),
                        div(id = "splash_container",
                            tags$video(id = "splash_dark", src = "splash_dark.mp4", autoplay = NA, muted = NA, loop = NA),
                            tags$video(id = "splash_light", src = "splash_light.mp4", autoplay = NA, muted = NA, loop = NA),
                            tags$video(id = "splash_dark_blue", src = "splash_dark_blue.mp4", autoplay = NA, muted = NA, loop = NA),
                            tags$video(id = "splash_light_blue", src = "splash_light_blue.mp4", autoplay = NA, muted = NA, loop = NA)
                        )
                    )
                ),
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
            .viper-title {
                margin-top: 15px;
                margin-bottom: 15px;
                text-align: left;
                font-family: 'Segoe UI', sans-serif;
            }

            .viper-brand {
                font-size: 48px;
                font-weight: 800;
                color: #228B22;
                letter-spacing: 2px;
            }

            .viper-subtitle {
                font-size: 18px;
                font-weight: 400;
                color: #444;
                letter-spacing: 1px;
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
            .dark-mode .viper-brand {
                color: #1db954;
            }
            .dark-mode .viper-subtitle {
                color: #bbb;
            }

            /* Blue Mode Overrides */
            .blue-mode .nav-tabs > li > a {
                color: #00BFFF !important;
            }
            .blue-mode .nav-tabs > li.active > a {
                background-color: #1E90FF !important;
                color: white !important;
            }
            .blue-mode .btn-primary {
                background-color: #00BFFF !important;
                color: white;
            }
            .blue-mode .mainPanel h4,
            .blue-mode .tab-content h4 {
                color: #00BFFF !important;
            }
            .blue-mode .viper-brand {
                color: #00BFFF;
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

            function toggleBlueMode() {
                var body = document.body;
                var isBlue = body.classList.toggle('blue-mode');
                localStorage.setItem('blue-mode', isBlue);
            }

            document.addEventListener('DOMContentLoaded', function() {
                if (localStorage.getItem('blue-mode') === 'true') {
                    document.body.classList.add('blue-mode');
                    document.getElementById('blue_mode_toggle').checked = true;
                }
            })
        "))
    )
)
