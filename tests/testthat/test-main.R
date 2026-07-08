test_that("main.R CLI creates batch-corrected output", {
  setup <- setup_cli_workspace("mosuite_batch_correct_counts_test_")
  on.exit(unlink(setup$workspace, recursive = TRUE), add = TRUE)

  old_wd <- getwd()
  setwd(setup$code_dir)
  on.exit(setwd(old_wd), add = TRUE)

  exit_code <- system2("Rscript", args = c("main.R", common_cli_args))
  expect_equal(exit_code, 0, info = "main.R should execute without error")

  expect_outputs_created(setup$results_dir)
})

test_that("run wrapper executes and creates batch-corrected output", {
  setup <- setup_cli_workspace("mosuite_batch_correct_counts_run_test_")
  on.exit(unlink(setup$workspace, recursive = TRUE), add = TRUE)

  file.copy(
    file.path(setup$repo_root, "code", "run"),
    file.path(setup$code_dir, "run"),
    overwrite = TRUE
  )

  old_wd <- getwd()
  setwd(setup$code_dir)
  on.exit(setwd(old_wd), add = TRUE)

  exit_code <- system2("bash", args = c("run", common_cli_args))
  expect_equal(exit_code, 0, info = "run script should execute without error")

  expect_outputs_created(setup$results_dir)
})

test_that("main.R accepts updated batch correction plotting arguments", {
  setup <- setup_cli_workspace("mosuite_batch_correct_counts_plot_args_test_")
  on.exit(unlink(setup$workspace, recursive = TRUE), add = TRUE)

  old_wd <- getwd()
  setwd(setup$code_dir)
  on.exit(setwd(old_wd), add = TRUE)

  exit_code <- system2(
    "Rscript",
    args = c(
      "main.R",
      common_cli_args,
      "--add_label_to_pca=FALSE",
      "--principal_component_on_x_axis=1",
      "--principal_component_on_y_axis=2",
      "--legend_position_for_pca=bottom",
      "--point_size_for_pca=3",
      "--color_histogram_by_group=TRUE",
      "--legend_font_size_for_histogram=",
      "--legend_position_for_histogram=top",
      "--number_of_histogram_legend_columns=6",
      "--plot_corr_matrix_heatmap=FALSE",
      "--interactive_plots=FALSE"
    )
  )
  expect_equal(
    exit_code,
    0,
    info = "main.R should accept updated plotting arguments"
  )

  expect_outputs_created(setup$results_dir)
})

test_that("capsule environment installs MOSuite from FigOutSync", {
  repo_root <- normalizePath(file.path(dirname(getwd()), ".."))
  post_install <- file.path(repo_root, "environment", "postInstall")
  post_install_lines <- readLines(post_install, warn = FALSE)

  expect_true(
    any(grepl("CCBR/MOSuite", post_install_lines, fixed = TRUE)),
    info = "postInstall should install MOSuite from the package repository"
  )
  expect_true(
    any(grepl("ref = \"FigOutSync\"", post_install_lines, fixed = TRUE)),
    info = "postInstall should use the FigOutSync package branch"
  )
  expect_false(
    any(grepl("ref = \"main\"", post_install_lines, fixed = TRUE)),
    info = "postInstall should not install MOSuite from main for this capsule PR"
  )
})

test_that("app panel exposes updated batch correction plotting parameters", {
  repo_root <- normalizePath(file.path(dirname(getwd()), ".."))
  app_panel <- file.path(repo_root, ".codeocean", "app-panel.json")
  app_panel_text <- paste(readLines(app_panel, warn = FALSE), collapse = "\n")

  expected_parameters <- c(
    "samples_to_rename",
    "add_label_to_pca",
    "principal_component_on_x_axis",
    "principal_component_on_y_axis",
    "legend_position_for_pca",
    "point_size_for_pca",
    "color_histogram_by_group",
    "legend_font_size_for_histogram",
    "legend_position_for_histogram",
    "number_of_histogram_legend_columns",
    "plot_corr_matrix_heatmap",
    "interactive_plots"
  )

  for (parameter in expected_parameters) {
    expect_true(
      grepl(parameter, app_panel_text, fixed = TRUE),
      info = paste("app panel should expose", parameter)
    )
  }
})
