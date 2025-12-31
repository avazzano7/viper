import matplotlib.pyplot as plt
import matplotlib.patches as patches


def plot_mutation_density(density_df, hotspots_df=None, genome_length=None, title="Viral Mutation Hotspot Detection", figsize=(12, 4), save_path=None):
    """
    Plot mutation density across the genome and highlight hotspots.

    Parameters:
    - density_df: pd.DataFrame with columns ['window_midpoint', 'density']
    - hotspots_df: pd.DataFrame with same columns as density_df for hotspot windows (optional)
    - genome_length: int, length of the genome for x-axis limits (optional)
    - title: str, plot title
    - figsize: tuple, figure size
    """

    plt.figure(figsize=figsize)
    plt.plot(
        density_df["window_midpoint"],
        density_df["density"],
        label="Mutation Density",
        color="blue"
    )

    if hotspots_df is not None and not hotspots_df.empty:
        plt.scatter(
            hotspots_df["window_midpoint"],
            hotspots_df["density"],
            color="red",
            label="Hotspots",
            zorder=5
        )

        # Highlight hotspot windows as shaded regions
        ax = plt.gca()
        for _, row in hotspots_df.iterrows():
            start = row["start"]
            end = row["end"]
            ax.add_patch(
                patches.Rectangle(
                    (start, 0),
                    end - start,
                    max(density_df["density"].max(), 1)*1.1,
                    color="red",
                    alpha=0.2
                )
            )

    plt.xlabel("Genome Position")
    plt.ylabel("Mutation Density")
    plt.title(title)
    plt.legend()
    plt.xlim(0, genome_length if genome_length else density_df["window_midpoint"].max())
    plt.tight_layout()

    if save_path:
        plt.savefig(save_path, dpi=300)
        plt.close()
        print(f"Hotspot Plot saved at {save_path}")
    else:
        plt.show()