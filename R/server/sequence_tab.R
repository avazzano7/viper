observeEvent(input$read, {
  req(input$file)

  tryCatch({
    fasta_file <- read.fasta(input$file$datapath, seqtype = "DNA", as.string = TRUE)
    seqs <- sapply(fasta_file, as.character)

    if (length(seqs) < 2) stop("At least two sequences are required.")

    sequences(seqs)

    output$status <- renderText("File read successfully.")
    output$sequences <- renderText(paste("Extracted Sequences:\n", paste(seqs, collapse = "\n")))

    lengths <- nchar(seqs)
    gc_content <- sapply(seqs, function(seq) {
      (sum(toupper(unlist(strsplit(seq, ""))) %in% c("G", "C")) / nchar(seq)) * 100
    })

    output$metrics <- renderTable({
      data.frame(Sequence = names(fasta_file), Length = lengths, GC_Content = gc_content)
    }, class = "gc-table")

  }, error = function(e) {
    output$status <- renderText(paste("Error:", e$message))
    output$sequences <- renderText("")
    phylo_tree(NULL)
  })
})
