all_codons <- c("AAA", "AAC", "AAG", "AAT", "ACA", "ACC", "ACG", "ACT",
                "AGA", "AGC", "AGG", "AGT", "ATA", "ATC", "ATG", "ATT",
                "CAA", "CAC", "CAG", "CAT", "CCA", "CCC", "CCG", "CCT",
                "CGA", "CGC", "CGG", "CGT", "CTA", "CTC", "CTG", "CTT",
                "GAA", "GAC", "GAG", "GAT", "GCA", "GCC", "GCG", "GCT",
                "GGA", "GGC", "GGG", "GGT", "GTA", "GTC", "GTG", "GTT",
                "TAA", "TAC", "TAG", "TAT", "TCA", "TCC", "TCG", "TCT",
                "TGA", "TGC", "TGG", "TGT", "TTA", "TTC", "TTG", "TTT")

output$codon_usage <- renderTable({
  req(sequences())

  codon_counts <- sapply(sequences(), function(seq) {
    seq <- substring(seq, 1, floor(nchar(seq) / 3) * 3)
    codons <- substring(seq, seq(1, nchar(seq) - 2, by = 3), seq(3, nchar(seq), by = 3))
    codons <- toupper(codons)
    codons <- codons[grepl("^[ATGC]{3}$", codons)]
    codon_table <- table(factor(codons, levels = all_codons))
    prop.table(codon_table) * 100
  })

  t(codon_counts)
})
