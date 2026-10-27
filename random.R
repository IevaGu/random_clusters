library(SingleCellExperiment)

run_random <- function(
  sce, n_cluster, seed, time
) {
  set.seed(seed)

  start_time <- Sys.time()

  random_clustering <- sample(
    seq_len(n_cluster),
    size = ncol(sce),
    replace = TRUE
  )

  end_time <- Sys.time()
  time_elapsed <- end_time - start_time
  print(paste("Random clustering. Total Time Elapsed:", time_elapsed))
  time$random <- time_elapsed

  return(list(
    cell_ids = colnames(sce),
    time = time,
    clusters = random_clustering
  ))
}
