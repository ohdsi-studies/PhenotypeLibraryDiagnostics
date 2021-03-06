# Code to be used  by the package maintainer.

# Format and check code ---------------------------------------------------------------------
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("PhenotypeLibraryDiagnostics")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------------------------
shell("rm extras/PhenotypeLibraryDiagnostics.pdf")
shell("R CMD Rd2pdf ./ --output=extras/PhenotypeLibraryDiagnostics.pdf")

# Import phenotype and cohort definitions from Phenotype Library ----------------------------
source("extras/ImportFromPhenotypeLibrary.R")
importFromPhenotypeLibrary("../PhenotypeLibrary")

# Store R environment details in RENV lock file ---------------------------------------------------
OhdsiRTools::createRenvLockFile("PhenotypeLibraryDiagnostics")
