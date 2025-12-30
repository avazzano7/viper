import pandas as pd
import vcfpy
from Bio import SeqIO


def load_mutation_data_from_vcf(vcf_file, min_qual=20):
    """
    Load mutation data from a VCF file and count mutation occurrences by genome position.

    Parameters:
    - vcf_file (str): Path to the VCF file.
    - min_qual (float): Minimul QUAL score to include a variant (default: 20).

    Returns:
    - pd.DataFrame: Columns ['position', 'count'] with 0-based genome positions.
    """
    mutation_counts = {}

    reader = vcfpy.Reader.from_path(vcf_file)

    for record in reader:
        if record.QUAL is not None and record.QUAL < min_qual:
            continue
        pos = record.POS - 1  # Convert 1-based to 0-based indexing
        mutation_counts[pos] = mutation_counts.get(pos, 0) + 1

    df = pd.DataFrame(list(mutation_counts.items()), columns=['position', 'count'])
    return df


def get_genome_length_from_fasta(fasta_file):
    """
    Load the length of the viral genome from a FASTA file.

    Parameters:
    - fasta_file (str): Path to the FASTA file.

    Returns:
    - int: Length of the sequence.
    """
    record = next(SeqIO.parse(fasta_file, "fasta"))
    return len(record.seq)