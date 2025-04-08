observeEvent(sequences(), {
  req(sequences())

  seqs_bstring <- Biostrings::DNAStringSet(sequences())
  alignment <- msa(seqs_bstring, method = "ClustalW")

  aligned_seqs <- as.DNAbin(alignment)
  dist_matrix <- dist.dna(aligned_seqs, model = "raw")

  tree <- nj(dist_matrix)
  phylo_tree(tree)

  output$phylo_tree <- renderPlot({
    tip_labels <- names(sequences())
    plot.phylo(tree, main = "Phylogenetic Tree", tip.label = tip_labels, edge.width = 2)
  })
})
