test_that("code/run executes successfully with default CLI arguments", {
  # Create temporary workspace
  workspace <- tempfile("mosuite_batch_correct_test_")
  dir.create(workspace)
  on.exit(unlink(workspace, recursive = TRUE), add = TRUE)

  # Set up directory structure
  code_dir <- file.path(workspace, "code")
  data_dir <- file.path(workspace, "data")
  results_dir <- file.path(code_dir, "..", "results")
  dir.create(code_dir)
  dir.create(data_dir)
  dir.create(results_dir)

  # Get test data from package tests directory
  repo_root <- normalizePath(file.path(dirname(getwd()), ".."))
  test_data_file <- file.path(repo_root, "tests", "data", "moo-norm.rds")

  expect_true(
    file.exists(test_data_file),
    info = paste("Test data file should exist at", test_data_file)
  )
  file.copy(test_data_file, file.path(data_dir, "moo-norm.rds"))

  # Copy main.R and run script to workspace
  file.copy(
    file.path(repo_root, "code", "main.R"),
    file.path(code_dir, "main.R")
  )
  file.copy(
    file.path(repo_root, "code", "run"),
    file.path(code_dir, "run")
  )

  # Run the script from code directory
  old_wd <- getwd()
  setwd(code_dir)
  on.exit(setwd(old_wd), add = TRUE)

  # Execute run script with default CLI arguments
  exit_code <- system2(
    "bash",
    args = c(
      "run",
      "--print_plots=FALSE",
      "--save_plots=FALSE"
    )
  )

  # Check for successful execution
  expect_equal(exit_code, 0, info = "run script should execute without error")
  expect_true(
    file.exists(file.path(results_dir, "moo", "moo-batch.rds")),
    info = "Output file moo-batch.rds should be created"
  )

  # Validate output is a valid MOO object
  moo <- readr::read_rds(file.path(results_dir, "moo", "moo-batch.rds"))
  expect_true(
    S7::S7_inherits(moo, MOSuite::multiOmicDataSet),
    info = "Output should be an S7 multiOmicDataSet object"
  )

  # Validate batch column exists
  expect_true(
    "batch" %in% names(moo@counts),
    info = "Output should have batch column in moo@counts"
  )
})

test_that("code/run executes with custom CLI arguments", {
  # Create temporary workspace
  workspace <- tempfile("mosuite_batch_correct_custom_test_")
  dir.create(workspace)
  on.exit(unlink(workspace, recursive = TRUE), add = TRUE)

  # Set up directory structure
  code_dir <- file.path(workspace, "code")
  data_dir <- file.path(workspace, "data")
  results_dir <- file.path(code_dir, "..", "results")
  dir.create(code_dir)
  dir.create(data_dir)
  dir.create(results_dir)

  # Get test data from package tests directory
  repo_root <- normalizePath(file.path(dirname(getwd()), ".."))
  test_data_file <- file.path(repo_root, "tests", "data", "moo-norm.rds")

  # Copy test data to workspace
  file.copy(test_data_file, file.path(data_dir, "moo-norm.rds"))

  # Copy main.R and run script to workspace
  file.copy(
    file.path(repo_root, "code", "main.R"),
    file.path(code_dir, "main.R")
  )
  file.copy(
    file.path(repo_root, "code", "run"),
    file.path(code_dir, "run")
  )

  # Run the script from code directory
  old_wd <- getwd()
  setwd(code_dir)
  on.exit(setwd(old_wd), add = TRUE)

  # Execute run script with custom CLI arguments
  exit_code <- system2(
    "bash",
    args = c(
      "run",
      "--count_type=norm",
      "--sub_count_type=voom",
      "--batch_colname=Batch",
      "--covariates_colnames=Group",
      "--print_plots=FALSE",
      "--save_plots=FALSE"
    )
  )

  # Check for successful execution
  expect_equal(
    exit_code,
    0,
    info = "run script with custom args should execute without error"
  )
  expect_true(
    file.exists(file.path(results_dir, "moo", "moo-batch.rds")),
    info = "Output file moo.rds should be created with custom args"
  )

  # Validate output is a valid MOO object
  moo <- readr::read_rds(file.path(results_dir, "moo", "moo-batch.rds"))
  expect_true(
    S7::S7_inherits(moo, MOSuite::multiOmicDataSet),
    info = "Output should be an S7 multiOmicDataSet object"
  )

  # Validate batch column exists
  expect_true(
    "batch" %in% names(moo@counts),
    info = "Output should have batch column in moo@counts"
  )
})
