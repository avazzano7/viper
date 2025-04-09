output$summary_ui <- renderUI({
    req(sequences())

    seqs <- sequences()
    lengths <- nchar(seqs)
    gc_content <- sapply(seqs, function(seq) {
        (sum(toupper(unlist(strsplit(seq, ""))) %in% c("G", "C")) / nchar(seq)) * 100
    })

    tagList(
        p(strong("Number of sequences:"), length(seqs)),
        p(strong("Sequence names:"), paste(names(seqs), collapse = ", ")),
        p(strong("Length range:"), paste0(min(lengths), " - ", max(lengths), " bp")),
        p(strong("Average GC content:"), paste(round(mean(gc_content), 2), "%")),
        hr(),
        tableOutput("summary_table")
    )
})

output$summary_table <- renderTable({
    req(sequences())

    seqs <- sequences()
    lengths <- nchar(seqs)
    gc_content <- sapply(seqs, function(seq) {
        (sum(toupper(unlist(strsplit(seq, ""))) %in% c("G", "C")) / nchar(seq)) * 100
    })

    data.frame(
        Sequence = names(seqs),
        Length = lengths,
        GC_Content = round(gc_content, 2)
    )
})