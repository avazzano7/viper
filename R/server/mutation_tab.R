observeEvent(sequences(), {
  req(sequences())

  reference_seq <- sequences()[[1]]
  mutation_matrix <- sapply(sequences(), function(seq) {
    as.integer(strsplit(reference_seq, "")[[1]] != strsplit(seq, "")[[1]])
  })

  mutation_data(mutation_matrix)

  output$mutation_heatmap <- renderPlot({
    mutation_melted <- reshape2::melt(mutation_matrix)
    colnames(mutation_melted) <- c("Position", "Sequence", "Mutation")

    ggplot(mutation_melted, aes(x = Position, y = Sequence, fill = Mutation)) +
      geom_tile() +
      scale_fill_gradient(low = "white", high = "red") +
      theme_minimal() +
      labs(title = "Mutation Heatmap", x = "Position", y = "Sequence") + 
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
  })
})
