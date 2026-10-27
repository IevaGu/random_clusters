# Random Clustering Baseline for OmniBenchmark

This repository contains a simple random clustering method implemented as an OmniBenchmark module.

The method serves as a baseline for evaluating clustering performance. Each cell is assigned randomly to one of a predefined number of clusters, allowing the resulting Adjusted Rand Index (ARI) to be compared with clustering methods such as Leiden.

## Method

The number of clusters is determined from the true number of clusters provided by the benchmark:

```text
n_cluster = true number of clusters + d_cluster
```

Each cell is then randomly assigned to one of these clusters.

A random seed is provided as a parameter to ensure reproducibility.

## Repository structure

```text
.
├── run.R        # OmniBenchmark entry point
├── random.R     # Random clustering implementation
├── environment.yml
└── README.md
```

## Parameters

The module uses the following parameters:

- `method_name`: specifies the clustering method (`random`)
- `d_cluster`: adjusts the number of clusters relative to the true number of clusters
- `seed`: random number generator seed used for reproducible cluster assignments

## Random clustering

The clustering is generated in R using:

```r
set.seed(seed)

random_clustering <- sample(
  seq_len(n_cluster),
  size = ncol(sce),
  replace = TRUE
)
```

Each cell therefore receives a random cluster label between `1` and `n_cluster`.

## Inputs

The module expects:

- an `.h5ad` single-cell dataset
- a file containing the true number of clusters

## Outputs

The module produces:

- `*.clusters.tsv` — cell IDs and their randomly assigned cluster labels
- `*.timings.json` — runtime information for the clustering step

The cluster output can subsequently be evaluated using OmniBenchmark metrics such as the Adjusted Rand Index (ARI).

## Purpose

The random clustering method provides a baseline representing clustering performance expected without using biological structure in the data. Its ARI can be compared with data-driven methods such as Leiden clustering to assess how much better those methods perform than random assignment.