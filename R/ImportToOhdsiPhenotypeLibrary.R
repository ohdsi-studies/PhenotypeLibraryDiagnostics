# Copyright 2022 Observational Health Data Sciences and Informatics
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

#' import output to phenotype library
#'
#' @details
#' This function compares a given Cohort Diagnostics output and evaluates its eligibility to be imported
#' into the OHDSI Phenotype library. To achieve this it perfoms the following tasks
#' 1) Look in the zip file containing the Cohort Diagnostics output in results data model for a data source.
#' 2) Looks for the metadata.csv file to obtain execution information. e.g. What version of CohortDiagnostics was used. Was it
#' executed as part of a study package? Were there any problems/interruptions during the execution. What were the parameters
#' set at the time of the execution and is the output expected to have the minimum components needs for the phenotype library.
#' 3) Looks at output files and check if the output has the minimum files needs for the Phenotype Library,
#' 4) Check the cohort definitions json/sql in the cohort table and check if they match the cohort json/sql in the OHDSI Phenotype library.
#' 5) Based on these information make a determination if the output may be importable to the OHDSI Phenotype library. If not importable,
#' then provide information as to why it is not possible.
#'
#' @param outputZipFile   An output zip file containing csv files output by Cohort Diagnostics.
#'
#' @export
isOutputZipFileImportableToOhdsiPhenotypeLibrary <-
  function(outputZipFile) {
    
  }
