# When the user clicks the button, store the file info & estimate time immediately
# Step 1: Respond immediately on button click
observeEvent(input$read, {
  req(input$file)

  file_info <- input$file
  file_kb <- file_info$size / 1024
  estimated_time <- round(file_kb * 0.05, 1)

  output$status <- renderText("Reading and processing file...")
  output$estimated_time <- renderText({
    paste("Estimated processing time:", estimated_time, "seconds")
  })

  # Force UI to update, then defer the heavy work
  later::later(function() {
    file_to_process(file_info)
  }, delay = 0.05)
})



observeEvent(file_to_process(), {
  req(file_to_process())
  file_info <- file_to_process()

  tryCatch({
    fasta_file <- read.fasta(file_info$datapath, seqtype = "DNA", as.string = TRUE)
    seqs <- setNames(sapply(fasta_file, as.character), names(fasta_file))

    if (length(seqs) < 3) stop("At least three sequences are required.")

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
    output$estimated_time <- renderText("")
    phylo_tree(NULL)
  })
})
