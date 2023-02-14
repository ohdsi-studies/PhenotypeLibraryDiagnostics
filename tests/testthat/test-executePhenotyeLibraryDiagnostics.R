library(testthat)
testthat::test_that("Testing if package can execute", {
  folder <- tempfile()
  dir.create(folder, recursive = TRUE)

  PhenotypeLibraryDiagnostics::executePhenotyeLibraryDiagnostics(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = "main",
    vocabularyDatabaseSchema = "main",
    cohortDatabaseSchema = "main",
    cohortTable = "c",
    outputFolder = folder
  )

  unlink(x = folder, recursive = TRUE, force = TRUE)
})
