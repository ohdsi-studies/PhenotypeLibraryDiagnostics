# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of PhenotypeLibraryDiagnostics
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Format and check code ---------------------------------------------------------------------
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("PhenotypeLibraryDiagnostics")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------------------------
shell("rm extras/PhenotypeLibraryDiagnostics.pdf")
shell("R CMD Rd2pdf ./ --output=extras/PhenotypeLibraryDiagnostics.pdf")

# Import phenotype and cohort definitions from Phenotype Library ----------------------------
phenotypeLibraryFolder <- "../PhenotypeLibrary"
phenotypeFolders <- list.files(phenotypeLibraryFolder, pattern = "[0-9]+", full.names = TRUE)

# Phenotype descriptions
phenotypeDescription <- lapply(file.path(phenotypeFolders, "phenotypeDescription.csv"), readr::read_csv, col_types = readr::cols())
phenotypeDescription <- dplyr::bind_rows(phenotypeDescription)
readr::write_csv(phenotypeDescription, "inst/settings/phenotypeDescription.csv")

# Cohort descriptions
cohortDescription <- lapply(file.path(phenotypeFolders, "cohortDescription.csv"), readr::read_csv, col_types = readr::cols())
cohortDescription <- dplyr::bind_rows(cohortDescription)
readr::write_csv(cohortDescription, "inst/settings/cohortDescription.csv")

# JSON
unlink("inst/cohorts", recursive = TRUE)
dir.create("inst/cohorts", recursive = TRUE)
jsonFiles <- list.files(phenotypeLibraryFolder, pattern = "[0-9]+.json", recursive = TRUE, full.names = TRUE)
jsonFiles <- jsonFiles[grepl("[0-9]+/[0-9]+.json$", jsonFiles)]
all(file.copy(jsonFiles, file.path("inst/cohorts", basename(jsonFiles))))

# SQL
unlink("inst/sql/sql_server", recursive = TRUE)
dir.create("inst/sql/sql_server", recursive = TRUE)
sqlFiles <- list.files(phenotypeLibraryFolder, pattern = "[0-9]+.sql", recursive = TRUE, full.names = TRUE)
sqlFiles <- sqlFiles[grepl("[0-9]+/[0-9]+.sql$", sqlFiles)]
all(file.copy(sqlFiles, file.path("inst/sql/sql_server", basename(sqlFiles))))


# Store R environment details in RENV lock file ---------------------------------------------------
OhdsiRTools::createRenvLockFile("PhenotypeLibraryDiagnostics")