# VIPER

**VIPER** — Viral Interpretation and Protein Evolution Resource — is a Python library designed to detect mutation hotspots in viral genomes and annotate their potential functional impacts on viral proteins.

---

## Features

- Identify mutation hotspots across viral genomes using a sliding window approach  
- Map hotspots to viral protein domains and functional regions  
- Integrate evolutionary conservation scores to prioritize biologically relevant hotspots  
- Visualize mutation density along genomes with annotated functional regions  
- Support for standard bioinformatics formats: FASTA, VCF, GFF/BED  

---

## Installation

```bash
pip install viper
```

## Quick Start
```python
from viper import hotspot, annotation, visualization

# Load your aligned viral genome sequences or mutation data
mutation_data = hotspot.load_mutation_data("data/example_mutations.vcf")

# Detect mutation hotspots
hotspots = hotspot.detect_hotspots(mutation_data, window_size=100, step_size=25)

# Load protein functional annotations
annotations = annotation.load_annotations("data/example_annotations.gff")

# Map hotspots to protein domains
annotated_hotspots = annotation.map_hotspots_to_proteins(hotspots, annotations)

# Visualize mutation hotspots with functional annotations
visualization.plot_hotspots(annotated_hotspots)
```

