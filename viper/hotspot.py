import pandas as pd
import numpy as np
from scipy.stats import poisson


def sliding_window_mutation_density(mutations_df, genome_length, window_size=100, step_size=25, save_path=None):
    """
    Calculate mutation density across the genome using a sliding window.

    Parameters:
    - mutations_df: pd.DataFrame with columns ['position', 'count'].
    - genome_length: int, length of the viral genome.
    - window_size: int, size of the sliding window.
    - step_size: int, step size to move the window.

    Returns:
    - pd.DataFrame with columns:
      ['start', 'end', 'window_midpoint', 'mutation_count', 'density']
    """

    if mutations_df.empty:
        raise ValueError("mutations_df is empty — no mutations to analyze.")

    if genome_length < window_size:
        raise ValueError(
            f"window_size ({window_size}) cannot exceed genome_length ({genome_length})."
        )

    windows = []

    for start in range(0, genome_length - window_size + 1, step_size):
        end = start + window_size

        window_mutations = mutations_df[
            (mutations_df["position"] >= start) &
            (mutations_df["position"] < end)
        ]

        mutation_count = window_mutations["count"].sum()
        density = mutation_count / window_size
        midpoint = (start + end) // 2

        windows.append({
            "start": start,
            "end": end,
            "window_midpoint": midpoint,
            "mutation_count": mutation_count,
            "density": density
        })

    df = pd.DataFrame(windows)

    if save_path:
        df.to_csv(save_path)
        print(f"Mutation Density CSV saved at {save_path}")

    return df



def detect_hotspots(mutation_density_df, density_threshold=None, percentile=95, save_path=None):
    """
    Identify mutation hotspots based on mutation density threshold or percentile.

    Parameters:
    - mutation_density_df: pd.DataFrame output of sliding_window_mutation_density.
    - density_threshold: float, density cutoff to call a hotspot. If None, uses percentile cutoff.
    - percentile: int, percentile cutoff to call hotspots if density_threshold is None (default 95).

    Returns:
    - pd.DataFrame filtered for windows considered hotspots.
    """
    if density_threshold is None:
        density_threshold = np.percentile(mutation_density_df['density'], percentile)
    
    # Calculate percentile based on the threshold
    def get_percentile(density_value):
        return (mutation_density_df['density'] < density_value).sum() / len(mutation_density_df) * 100
    
    mutation_density_df['density_percentile'] = mutation_density_df['density'].apply(get_percentile)

    hotspots = mutation_density_df[mutation_density_df['density'] >= density_threshold].copy()
    hotspots.reset_index(drop=True, inplace=True)

    if save_path:
        hotspots.to_csv(save_path)
        print(f"Hotspot CSV saved at {save_path}")

    return hotspots