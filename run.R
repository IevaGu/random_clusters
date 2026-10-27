#!/usr/bin/env Rscript

library(argparse)
library(jsonlite)
library(zellkonverter)

parser <- ArgumentParser(description = "Random clustering baseline")

parser$add_argument(
  "--output_dir", "-o",
  dest = "output_dir", type = "character",
  help = "output directory where files will be saved",
  default = getwd(), required = TRUE
)
parser$add_argument(
  "--name", "-n",
  dest = "name", type = "character",
  help = "name of the module",
  required = TRUE
)
parser$add_argument(
  "--data.h5ad",
  dest = "data_path", type = "character",
  help = "input data h5ad path",
  required = TRUE
)
parser$add_argument(
  "--data.clusters_truth_num",
  dest = "clusters_truth_num_path", type = "character",
  help = "input true number of clusters path",
  required = TRUE
)
parser$add_argument(
  "--method_name",
  dest = "method_name", type = "character",
  help = "name of the method",
  required = TRUE
)
parser$add_argument(
  "--d_cluster",
  dest = "d_cluster", type = "integer",
  help = "delta number of clusters with respect to true number of clusters",
  required = TRUE
)
parser$add_argument(
  "--seed",
  dest = "seed", type = "integer",
  help = "random seed",
  required = TRUE
)

args <- parser$parse_args()

cargs <- commandArgs(trailingOnly = FALSE)
m <- grep("--file=", cargs)
run_dir <- dirname(gsub("--file=", "", cargs[[m]]))

timings_path <- file.path(args$output_dir, paste0(args$name, ".timings.json"))
clustering_info_path <- file.path(args$output_dir, paste0(args$name, ".clustering_info.json"))
clusters_path <- file.path(args$output_dir, paste0(args$name, ".clusters.tsv"))
pca_path <- file.path(args$output_dir, paste0(args$name, ".pca.tsv"))

sce <- readH5AD(args$data_path, reader = "python")
clusters_truth_num <- as.integer(readLines(args$clusters_truth_num_path, n = 1))
n_cluster <- clusters_truth_num + args$d_cluster

# time object to store time involved (in seconds) in each step
time <- list(
  random = NA_real_
)

clustering_info <- list(
  resolutions = list(),
  num_runs = list(random = 1)
)

# source and run appropriate method
if (args$method_name == "random") {
  random_r_path <- file.path(run_dir, "random.R")
  source(random_r_path)
  output_data <- run_random(
    sce,
    n_cluster,
    args$seed,
    time
  )
}

# write outputs to files
output_data$time <- lapply(output_data$time, function(x) {
  as.numeric(x, units = "secs")
})
write_json(
  output_data$time, timings_path,
  auto_unbox = TRUE, pretty = TRUE
)
write_json(
  clustering_info, clustering_info_path,
  auto_unbox = TRUE, pretty = TRUE
)
write.table(
  data.frame(
    cell_id = output_data$cell_ids,
    leiden = output_data$clusters
  ),
  clusters_path,
  sep = "\t", quote = F, row.names = F
)
pca <- data.frame(
  cell_id = output_data$cell_ids,
  PC1 = 0
)
write.table(
  pca,
  pca_path,
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)
cat(str(output_data))
