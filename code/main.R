#!/usr/bin/env Rscript
library(argparse)
library(glue)
devtools::load_all('/code/MOSuite')
library(readr)
library(stringr)
library(dplyr)

# set up capsule environment
setup_capsule_environment()

# parse CLI arguments
parser <- ArgumentParser()

parser$add_argument("--count_type", type = "character", default = "norm")
parser$add_argument("--sub_count_type", type = "character", default = "voom")
parser$add_argument(
  "--sample_id_colname",
  type = "character",
  default = NULL,
  help = "Column name for sample IDs"
)
parser$add_argument(
  "--feature_id_colname",
  type = "character",
  default = NULL,
  help = "Column name for feature IDs"
)
parser$add_argument(
  "--samples_to_include",
  type = "character",
  default = "",
  help = "Comma-separated list of samples to include"
)
parser$add_argument(
  "--covariates_colnames",
  type = "character",
  default = "Group",
  help = "Comma-separated list of covariate column names"
)
parser$add_argument(
  "--batch_colname",
  type = "character",
  default = "Batch",
  help = "Column name for batch information"
)
parser$add_argument(
  "--label_colname",
  type = "character",
  default = NULL,
  help = "Column name for sample labels"
)
parser$add_argument(
  "--colors_for_plots",
  type = "character",
  default = "",
  help = "Comma-separated list of colors for plots"
)
parser$add_argument(
  "--print_plots",
  type = "logical",
  default = TRUE,
  help = "Whether to print plots to console"
)
parser$add_argument(
  "--save_plots",
  type = "logical",
  default = TRUE,
  help = "Whether to save plots to files"
)

args <- parser$parse_args()

# Set plot options
options(print_plots = args$print_plots, save_plots = args$save_plots)

# load multiOmicDataSet from data directory
moo <- load_moo_from_data_dir()

# run MOSuite
moo |>
  batch_correct_counts(
    count_type = args$count_type,
    sub_count_type = args$sub_count_type,
    sample_id_colname = args$sample_id_colname,
    feature_id_colname = args$feature_id_colname,
    samples_to_include = parse_optional_vector(args$samples_to_include),
    covariates_colnames = parse_vector_with_default(
      args$covariates_colnames,
      "Group"
    ),
    batch_colname = args$batch_colname,
    label_colname = args$label_colname,
    colors_for_plots = parse_optional_vector(args$colors_for_plots),
    print_plots = args$print_plots,
    save_plots = args$save_plots
  ) |>
  write_rds(file.path(getOption("moo_plots_dir"), "..", "moo", "moo-batch.rds"))
