#!/usr/bin/env Rscript
rlang::global_entrace()
library(argparse)
library(glue)
library(MOSuite)
library(readr)
library(stringr)
library(dplyr)

# set up results directory
results_dir <- file.path('..','results')
plots_dir <- file.path(results_dir, 'figures')
options(moo_plots_dir = plots_dir, moo_save_plots = TRUE)

# log installed packages & versions
pkg_versions <- tibble::as_tibble(installed.packages())
write_csv(pkg_versions, file.path(results_dir, 'r-packages.csv'))

# parse CLI arguments
parser <- ArgumentParser()

parser$add_argument("--count_type", type="character", default="norm")
parser$add_argument("--sub_count_type", type="character", default="voom")
parser$add_argument("--sample_id_colname", type="character", default=NULL, help="Column name for sample IDs")
parser$add_argument("--feature_id_colname", type="character", default=NULL, help="Column name for feature IDs")
parser$add_argument("--samples_to_include", type="character", default="", help="Comma-separated list of samples to include")
parser$add_argument("--covariates_colnames", type="character", default="Group", help="Comma-separated list of covariate column names")
parser$add_argument("--batch_colname", type="character", default="Batch", help="Column name for batch information")
parser$add_argument("--label_colname", type="character", default=NULL, help="Column name for sample labels")
parser$add_argument("--colors_for_plots", type="character", default="", help="Comma-separated list of colors for plots")

args <- parser$parse_args()

parse_optional_vector <- function(x) {
    if (is.null(x) || identical(x, "") || length(x) == 0) {
        return(NULL)
    }
    return(trimws(unlist(strsplit(x, ","))))
}

parse_vector_with_default <- function(x, default) {
    parsed <- parse_optional_vector(x)
    if (is.null(parsed)) {
        return(default)
    }
    return(parsed)
}

# validate inputs
regex_moo <- ".*\\.rds$"
data_files <- list.files(file.path('../data'), recursive = TRUE, full.names = TRUE)
moo_files <- Filter(\(x) str_detect(x, regex(regex_moo, ignore_case = TRUE)), data_files)

if (length(moo_files) == 0) {
    stop(glue("No files matching regex: {regex_moo}"))
}
moo_filename <- moo_files[1]
moo <- read_rds(moo_filename)
message(glue('Reading multiOmicDataSet from {moo_filename}'))
if (!inherits(moo, 'MOSuite::multiOmicDataSet')) {
    stop(glue('The input is not a multiOmicDataSet. class: {class(moo)}'))
}

# run MOSuite
moo |> 
    batch_correct_counts(
        count_type = args$count_type,
        sub_count_type = args$sub_count_type,
        sample_id_colname = args$sample_id_colname,
        feature_id_colname = args$feature_id_colname,
        samples_to_include = parse_optional_vector(args$samples_to_include),
        covariates_colnames = parse_vector_with_default(args$covariates_colnames, "Group"),
        batch_colname = args$batch_colname,
        label_colname = args$label_colname,
        colors_for_plots = parse_optional_vector(args$colors_for_plots)
        ) |> 
    write_rds(file.path(results_dir, 'moo', 'moo.rds'))