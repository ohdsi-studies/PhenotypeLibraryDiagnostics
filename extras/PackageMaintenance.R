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

# Format and check code ---------------------------------------------------
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("PhenotypeLibraryDiagnostics")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------
shell("rm extras/PhenotypeLibraryDiagnostics.pdf")
shell("R CMD Rd2pdf ./ --output=extras/PhenotypeLibraryDiagnostics.pdf")

# Insert cohort definitions from ATLAS into package -----------------------
table <- readr::read_csv("inst/settings/CohortsToCreate.csv")
table$name <- table$cohortId
table$atlasId <- table$webApiCohortId
readr::write_csv(table, "inst/settings/CohortsToCreate2.csv")
ROhdsiWebApi::insertCohortDefinitionSetInPackage(fileName = "inst/settings/CohortsToCreate.csv",
                                                 baseUrl = keyring::key_get("baseUrl"),
                                                 insertTableSql = FALSE,
                                                 insertCohortCreationR = FALSE,
                                                 generateStats = TRUE,
                                                 packageName = "PhenotypeLibraryDiagnostics")
unlink("inst/settings/CohortsToCreate2.csv")

# Store R environment details in RENV lock file ---------------------------
OhdsiRTools::createRenvLockFile("PhenotypeLibraryDiagnostics")