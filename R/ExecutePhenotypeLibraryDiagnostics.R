# Copyright 2023 Observational Health Data Sciences and Informatics
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

#' Execute the cohort diagnostics
#'
#' @details
#' This function executes the cohort diagnostics.
#'
#' @param connectionDetails                   An object of type \code{connectionDetails} as created
#'                                            using the
#'                                            \code{\link[DatabaseConnector]{createConnectionDetails}}
#'                                            function in the DatabaseConnector package.
#' @param cdmDatabaseSchema                   Schema name where your patient-level data in OMOP CDM
#'                                            format resides. Note that for SQL Server, this should
#'                                            include both the database and schema name, for example
#'                                            'cdm_data.dbo'.
#' @param cohortDatabaseSchema                Schema name where intermediate data can be stored. You
#'                                            will need to have write privileges in this schema. Note
#'                                            that for SQL Server, this should include both the
#'                                            database and schema name, for example 'cdm_data.dbo'.
#' @param vocabularyDatabaseSchema            Schema name where your OMOP vocabulary data resides. This
#'                                            is commonly the same as cdmDatabaseSchema. Note that for
#'                                            SQL Server, this should include both the database and
#'                                            schema name, for example 'vocabulary.dbo'.
#' @param cohortTable                         The name of the table that will be created in the work
#'                                            database schema. This table will hold the exposure and
#'                                            outcome cohorts used in this study.
#' @param tempEmulationSchema                 Some database platforms like Oracle and Impala do not
#'                                            truly support temp tables. To emulate temp tables,
#'                                            provide a schema with write privileges where temp tables
#'                                            can be created.
#' @param verifyDependencies                  Check whether correct package versions are installed?
#' @param outputFolder                        Name of local folder to place results; make sure to use
#'                                            forward slashes (/). Do not use a folder on a network
#'                                            drive since this greatly impacts performance.
#' @param databaseId                          A short string for identifying the database (e.g.
#'                                            'Synpuf').
#' @param cohortIds                           An optional parameter to filter the cohortIds in OHDSI Phenotype library to run.
#'                                            By Default all cohorts will be run.
#' @param databaseName                        The full name of the database (e.g. 'Medicare Claims
#'                                            Synthetic Public Use Files (SynPUFs)').
#' @param databaseDescription                 A short description (several sentences) of the database.
#' @param incrementalFolder                   Name of local folder to hold the logs for incremental
#'                                            run; make sure to use forward slashes (/). Do not use a
#'                                            folder on a network drive since this greatly impacts
#'                                            performance.
#' @param extraLog                            Do you want to add anything extra into the log?
#'
#' @export
executePhenotyeLibraryDiagnostics <- function(connectionDetails,
                                              cdmDatabaseSchema,
                                              vocabularyDatabaseSchema = cdmDatabaseSchema,
                                              cohortDatabaseSchema = cdmDatabaseSchema,
                                              cohortTable = "cohort",
                                              tempEmulationSchema = getOption("sqlRenderTempEmulationSchema"),
                                              verifyDependencies = TRUE,
                                              outputFolder,
                                              cohortIds = NULL,
                                              incrementalFolder = file.path(outputFolder, "incrementalFolder"),
                                              databaseId = "Unknown",
                                              databaseName = databaseId,
                                              databaseDescription = databaseId,
                                              extraLog = NULL) {
  options("CohortDiagnostics-FE-batch-size" = 5)

  if (!file.exists(outputFolder)) {
    dir.create(outputFolder, recursive = TRUE)
  }

  ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "log.txt"))
  ParallelLogger::addDefaultErrorReportLogger(file.path(outputFolder, "errorReportR.txt"))
  on.exit(ParallelLogger::unregisterLogger("DEFAULT_FILE_LOGGER", silent = TRUE))
  on.exit(
    ParallelLogger::unregisterLogger("DEFAULT_ERRORREPORT_LOGGER", silent = TRUE),
    add = TRUE
  )

  if (verifyDependencies) {
    ParallelLogger::logInfo("Checking whether correct package versions are installed")
    verifyDependencies()
  }

  if (!is.null(extraLog)) {
    ParallelLogger::logInfo(extraLog)
  }

  ParallelLogger::logInfo("Creating cohorts")

  cohortTableNames <- CohortGenerator::getCohortTableNames(cohortTable = cohortTable)

  # Next create the tables on the database
  CohortGenerator::createCohortTables(
    connectionDetails = connectionDetails,
    cohortTableNames = cohortTableNames,
    cohortDatabaseSchema = cohortDatabaseSchema,
    incremental = TRUE
  )

  # get cohort definitions from study package
  phenotypeLog <- PhenotypeLibrary::getPhenotypeLog()

  phenotypeLog <- phenotypeLog |>
    dplyr::filter(.data$isCirceJson == 1) |>
    dplyr::filter(stringr::str_detect(
      string = .data$cohortNameAtlas,
      pattern = stringr::fixed("[W]"),
      negate = TRUE
    )) |>
    dplyr::filter(stringr::str_detect(
      string = .data$cohortNameAtlas,
      pattern = stringr::fixed("[D]"),
      negate = TRUE
    ))

  cohortDefinitionSet <- PhenotypeLibrary::getPlCohortDefinitionSet(phenotypeLog$cohortId)

  if (!is.null(cohortIds)) {
    cohortDefinitionSet <- cohortDefinitionSet %>%
      dplyr::filter(.data$cohortId %in% c(cohortIds))
  }

  cohortDefinitionSetForCohortGenerator <- cohortDefinitionSet |>
    dplyr::filter(!.data$cohortId %in% c(344, 346)) # doctors office visit, and outpatient visit cohorts which are very large cohorts

  # Generate the cohort set
  CohortGenerator::generateCohortSet(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTableNames = cohortTableNames,
    cohortDefinitionSet = cohortDefinitionSetForCohortGenerator,
    incrementalFolder = incrementalFolder,
    incremental = TRUE
  )

  # export stats table to local
  CohortGenerator::exportCohortStatsTables(
    connectionDetails = connectionDetails,
    connection = NULL,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTableNames = cohortTableNames,
    cohortStatisticsFolder = outputFolder,
    incremental = TRUE
  )

  temporalStartDays <- c(
    # components displayed in cohort characterization
    -9999, # anytime prior
    -365, # long term prior
    -180, # medium term prior
    -30, # short term prior

    # components displayed in temporal characterization
    -365, # one year prior to -31
    -30, # 30 day prior not including day 0
    0, # index date only
    1, # 1 day after to day 30
    31,
    -9999 # Any time prior to any time future
  )

  temporalEndDays <- c(
    0, # anytime prior
    0, # long term prior
    0, # medium term prior
    0, # short term prior

    # components displayed in temporal characterization
    -31, # one year prior to -31
    -1, # 30 day prior not including day 0
    0, # index date only
    30, # 1 day after to day 30
    365,
    9999 # Any time prior to any time future
  )

  cohortBasedCovariateSettings <-
    FeatureExtraction::createCohortBasedTemporalCovariateSettings(
      analysisId = 150,
      covariateCohortDatabaseSchema = cohortDatabaseSchema,
      covariateCohortTable = cohortTableNames$cohortTable,
      covariateCohorts = cohortDefinitionSetForCohortGenerator |>
        dplyr::select(
          .data$cohortId,
          .data$cohortName
        ),
      valueType = "binary",
      temporalStartDays = temporalStartDays,
      temporalEndDays = temporalEndDays
    )

  featureBasedCovariateSettings <-
    FeatureExtraction::createTemporalCovariateSettings(
      useDemographicsGender = TRUE,
      useDemographicsAge = TRUE,
      useDemographicsAgeGroup = TRUE,
      useDemographicsRace = FALSE,
      useDemographicsEthnicity = FALSE,
      useDemographicsIndexYear = TRUE,
      useDemographicsIndexMonth = TRUE,
      useDemographicsIndexYearMonth = TRUE,
      useDemographicsPriorObservationTime = TRUE,
      useDemographicsPostObservationTime = TRUE,
      useDemographicsTimeInCohort = TRUE,
      useConditionOccurrence = FALSE,
      useProcedureOccurrence = FALSE,
      useDrugEraStart = FALSE,
      useMeasurement = FALSE,
      useConditionEraStart = FALSE,
      useConditionEraOverlap = FALSE,
      useConditionEraGroupStart = FALSE,
      # do not use because https://github.com/OHDSI/FeatureExtraction/issues/144
      useConditionEraGroupOverlap = FALSE,
      useDrugExposure = FALSE,
      # leads to too many concept id
      useDrugEraOverlap = FALSE,
      useDrugEraGroupStart = FALSE,
      # do not use because https://github.com/OHDSI/FeatureExtraction/issues/144
      useDrugEraGroupOverlap = FALSE,
      useObservation = FALSE,
      useVisitCount = FALSE,
      useVisitConceptCount = FALSE,
      useDeviceExposure = FALSE,
      useCharlsonIndex = FALSE,
      useDcsi = FALSE,
      useChads2 = FALSE,
      useChads2Vasc = FALSE,
      useHfrs = FALSE,
      temporalStartDays = temporalStartDays,
      temporalEndDays = temporalEndDays
    )

  featureExtractionCovariateSettings <-
    list(
      cohortBasedCovariateSettings,
      featureBasedCovariateSettings
    )


  cohortDefinitionSetForCohortDiagnostics <- cohortDefinitionSetForCohortGenerator

  # run cohort diagnostics
  CohortDiagnostics::executeDiagnostics(
    cohortDefinitionSet = cohortDefinitionSetForCohortDiagnostics, # removes reference cohort and very large Visit cohorts
    exportFolder = outputFolder,
    databaseId = databaseId,
    databaseName = databaseName,
    databaseDescription = databaseDescription,
    cohortDatabaseSchema = cohortDatabaseSchema,
    connectionDetails = connectionDetails,
    connection = NULL,
    cdmDatabaseSchema = cdmDatabaseSchema,
    tempEmulationSchema = tempEmulationSchema,
    cohortTable = cohortTable,
    cohortTableNames = cohortTableNames,
    vocabularyDatabaseSchema = vocabularyDatabaseSchema,
    cohortIds = NULL,
    cdmVersion = 5,
    runInclusionStatistics = TRUE,
    runIncludedSourceConcepts = TRUE,
    runOrphanConcepts = FALSE,
    runTimeSeries = FALSE,
    runVisitContext = TRUE,
    runBreakdownIndexEvents = TRUE,
    runIncidenceRate = TRUE,
    runCohortRelationship = FALSE,
    runTemporalCohortCharacterization = TRUE,
    temporalCovariateSettings = featureExtractionCovariateSettings,
    minCellCount = 5,
    incremental = TRUE,
    incrementalFolder = incrementalFolder
  )
}
