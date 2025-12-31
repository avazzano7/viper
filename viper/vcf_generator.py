from Bio import SeqIO
import datetime

def generate_vcf_from_alignment(ref_fasta, aligned_fasta, save_path):
    """
    Generate a VCF file of SNPs from aligned viral sequences against a reference genome.

    Parameters:
    - ref_fasta (str): Path to the reference genome FASTA (single sequence).
    - aligned_fasta (str): Path to multi-FASTA file with sequences aligned to the reference.
    - save_path (str): Path to write the output VCF file.
    """
    # Load reference sequence (assumed single record)
    ref_record = next(SeqIO.parse(ref_fasta, "fasta"))
    ref_seq = str(ref_record.seq).upper()

    # Load aligned sequences
    aligned_records = list(SeqIO.parse(aligned_fasta, "fasta"))

    # Prepare samples (FASTA headers)
    samples = [rec.id for rec in aligned_records]

    # Open output VCF file
    with open(save_path, 'w') as vcf:
        # Write VCF header
        vcf.write("##fileformat=VCFv4.2\n")
        vcf.write(f"##fileDate={datetime.datetime.now().strftime('%Y%m%d')}\n")
        vcf.write(f"##source=VIPER_vcf_generator\n")
        vcf.write(f"##reference={ref_record.id}\n")
        vcf.write("##INFO=<ID=NS,Number=1,Type=Integer,Description=\"Number of Samples With Data\">\n")
        vcf.write("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">\n")
        vcf.write("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t" + "\t".join(samples) + "\n")

        seq_len = len(ref_seq)
        valid_bases = {'A', 'C', 'G', 'T'}

        # Iterate over genome positions
        for pos in range(seq_len):
            ref_base = ref_seq[pos]
            if ref_base not in valid_bases:
                continue  # skip ambiguous/reference gaps

            # Collect alt alleles and genotypes per sample
            alt_alleles = set()
            genotypes = []

            for rec in aligned_records:
                base = rec.seq[pos].upper()
                if base == ref_base or base not in valid_bases:
                    genotypes.append("0")  # reference allele
                else:
                    alt_alleles.add(base)
                    genotypes.append("1")  # alternate allele

            if not alt_alleles:
                continue  # no variant at this position

            # For simplicity, only support single ALT allele per position (could be extended)
            if len(alt_alleles) > 1:
                # Skip multi-allelic for now or choose one arbitrarily
                # You can extend this to handle multiple ALT alleles later
                alt_allele = sorted(alt_alleles)[0]
            else:
                alt_allele = alt_alleles.pop()

            # Compose VCF record line
            chrom = ref_record.id
            vcf_pos = pos + 1  # 1-based
            var_id = "."  # no ID
            qual = "."  # unknown
            fltr = "PASS"
            info = f"NS={len(samples)}"
            fmt = "GT"
            sample_gts = "\t".join(genotypes)

            line = f"{chrom}\t{vcf_pos}\t{var_id}\t{ref_base}\t{alt_allele}\t{qual}\t{fltr}\t{info}\t{fmt}\t{sample_gts}\n"
            vcf.write(line)
            print(f"Mutation VCF saved at {save_path}")
