server <- function(input, output, session) {
    sequences <- reactiveVal(NULL)
    phylo_tree <- reactiveVal(NULL)
    mutation_data <- reactiveVal(NULL)
    file_to_process <- reactiveVal(NULL)

    # Automatically switch from splash to Summary tab after sequences are loaded
    observeEvent(sequences(), {
        req(sequences())
        updateTabsetPanel(session, "main_tabs", selected = "Summary")
    })

    source("R/server/summary_tab.R", local = TRUE)
    source("R/server/sequence_tab.R", local = TRUE)
    source("R/server/alignment_tab.R", local = TRUE)
    source("R/server/mutation_tab.R", local = TRUE)
    source("R/server/codon_tab.R", local = TRUE)
}
