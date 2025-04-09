# Define server logic
server <- function(input, output, session) {
    sequences <- reactiveVal(NULL)
    phylo_tree <- reactiveVal(NULL)
    mutation_data <- reactiveVal(NULL)
    file_to_process <- reactiveVal(NULL)

    source("R/server/summary_tab.R", local = TRUE)
    source("R/server/sequence_tab.R", local=TRUE)
    source("R/server/alignment_tab.R", local=TRUE)
    source("R/server/mutation_tab.R", local=TRUE)
    source("R/server/codon_tab.R", local=TRUE)
}
