library(magrittr)
importFromPhenotypeLibrary <- function(phenotypeLibraryFolder = "../PhenotypeLibrary") {
  phenotypeFolders <- list.files(file.path(phenotypeLibraryFolder,
                                           "inst"), pattern = "[0-9]+", full.names = TRUE)

  ParallelLogger::logInfo("Importing from ", length(phenotypeFolders), " phenotype folders")

  ParallelLogger::logInfo("- Importing phenotype descriptions to 'inst/settings/phenotypeDescription.csv'")

  # its possible for a phenotype to have no cohorts
  phenotypeDescription <- list()
  for (i in (1:length(phenotypeFolders))) {
    description <- readr::read_csv(file = file.path(phenotypeFolders[[i]],
                                                    "phenotypeDescription.csv"),
                                   col_types = readr::cols())
    if (nrow(description) > 0) {
      phenotypeDescription[[i]] <- description
    }
  }
  phenotypeDescription <- dplyr::bind_rows(phenotypeDescription)
  unlink("inst/settings/phenotypeDescription.csv")
  dir.create(path = "inst/settings", showWarnings = FALSE, recursive = TRUE)
  readr::write_excel_csv(x = phenotypeDescription,
                         file = "inst/settings/phenotypeDescription.csv",
                         na = "")

  ParallelLogger::logInfo("- Importing cohort descriptions to 'inst/settings/cohortDescription.csv'")
  cohortDescription <- list()
  for (i in (1:length(phenotypeFolders))) {
    description <- readr::read_csv(file = file.path(phenotypeFolders[[i]], "cohortDescription.csv"),
                                   col_types = readr::cols())
    if (nrow(description) > 0) {
      cohortDescription[[i]] <- description
    }
  }
  cohortDescription <- dplyr::bind_rows(cohortDescription)
  unlink("inst/settings/cohortDescription.csv")
  readr::write_excel_csv(cohortDescription, file = "inst/settings/cohortDescription.csv", na = "")

  # readr::write_excel_csv(x = phenotypeDescription %>% dplyr::inner_join(cohortDescription %>%
  # dplyr::select(phenotypeId) %>% dplyr::distinct()), file = 'inst/settings/phenotypeDescription.csv',
  # na = '')

  # readr::write_excel_csv(cohortDescription %>% dplyr::inner_join(phenotypeDescription %>%
  # dplyr::select(phenotypeId) %>% dplyr::distinct()), file = 'inst/settings/cohortDescription.csv', na
  # = '')

  ParallelLogger::logInfo("- Found ", nrow(cohortDescription), " cohort descriptions")

  # JSON
  ParallelLogger::logInfo("- Importing cohort JSON files to 'inst/cohorts'")
  unlink("inst/cohorts", recursive = TRUE)
  dir.create("inst/cohorts", recursive = TRUE)
  jsonFiles <- list.files(file.path(phenotypeLibraryFolder, "inst"),
                          pattern = "[0-9]+.json",
                          recursive = TRUE,
                          full.names = TRUE)
  jsonFiles <- jsonFiles[grepl("[0-9]+/[0-9]+.json$", jsonFiles)]
  success <- all(file.copy(jsonFiles, file.path("inst/cohorts", basename(jsonFiles))))
  if (!success) {
    stop("Error copying JSON files")
  }

  # SQL
  ParallelLogger::logInfo("- Importing cohort SQL files to 'inst/sql/sql_server'")
  unlink("inst/sql/sql_server", recursive = TRUE)
  dir.create("inst/sql/sql_server", recursive = TRUE)
  sqlFiles <- list.files(file.path(phenotypeLibraryFolder, "inst"),
                         pattern = "[0-9]+.sql",
                         recursive = TRUE,
                         full.names = TRUE)
  sqlFiles <- sqlFiles[grepl("[0-9]+/[0-9]+.sql$", sqlFiles)]
  success <- all(file.copy(sqlFiles, file.path("inst/sql/sql_server", basename(sqlFiles))))
  if (!success) {
    stop("Error copying SQL files")
  }

  ParallelLogger::logInfo("- Checking referential integrity")
  if (!setequal(phenotypeDescription$phenotypeId, unique(cohortDescription$phenotypeId))) {
    mismatch <- setdiff(phenotypeDescription$phenotypeId, unique(cohortDescription$phenotypeId))
    warning(paste0("Phenotype ID mismatch. The following mismatched ",
                   paste0(mismatch, collapse = ",")))
  }

  jsonCohortIds <- as.numeric(gsub(".json", "", basename(jsonFiles)))
  if (!setequal(jsonCohortIds, cohortDescription$cohortId)) {
    mismatch2 <- setdiff(jsonCohortIds, cohortDescription$cohortId)
    warning("Cohort ID mistmatch for JSON files. The following mismatched ",
            paste0(mismatch2, collapse = ","))
  }

  sqlCohortIds <- as.numeric(gsub(".sql", "", basename(sqlFiles)))
  if (!setequal(sqlCohortIds, cohortDescription$cohortId)) {
    mismatch3 <- setdiff(sqlCohortIds, cohortDescription$cohortId)
    warning("Cohort ID mistmatch for SQL files. The following mismatched ",
            paste0(mismatch3, collapse = ","))
  }
  ParallelLogger::logInfo("Done importing")
  invisible(NULL)
}
