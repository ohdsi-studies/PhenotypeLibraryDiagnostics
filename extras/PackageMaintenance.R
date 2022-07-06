# Code to be used  by the package maintainer.
library(magrittr)
# Format and check code ---------------------------------------------------------------------
styler::style_pkg()
OhdsiRTools::checkUsagePackage("PhenotypeLibraryDiagnostics")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------------------------
shell("rm extras/PhenotypeLibraryDiagnostics.pdf")
shell("R CMD Rd2pdf ./ --output=extras/PhenotypeLibraryDiagnostics.pdf")

# Store environment in which the study was executed -----------------------
OhdsiRTools::createRenvLockFile(rootPackage = "PhenotypeLibraryDiagnostics",
                                mode = "description",
                                ohdsiGitHubPackages = unique(c(OhdsiRTools::getOhdsiGitHubPackages())),
                                includeRootPackage = FALSE)
