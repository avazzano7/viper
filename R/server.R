# Define server logic
server <- function(input, output) {
    sequences <- reactiveVal(NULL)
    phylo_tree <- reactiveVal(NULL)
    mutation_data <- reactiveVal(NULL)

    source("R/server/sequence_tab.R", local=TRUE)
    source("R/server/alignment_tab.R", local=TRUE)
    source("R/server/mutation_tab.R", local=TRUE)
    source("R/server/codon_tab.R", local=TRUE)
}
