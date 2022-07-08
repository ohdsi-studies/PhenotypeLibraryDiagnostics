# Code to be used  by the package maintainer.
library(magrittr)
# Format and check code ---------------------------------------------------------------------
styler::style_pkg()
OhdsiRTools::checkUsagePackage("PhenotypeLibraryDiagnostics")
OhdsiRTools::updateCopyrightYearFolder()


# Update Description -----------------------------------------------------------------------------
remotes::install_github(repo = "OHDSI/PhenotypeLibrary", quiet = TRUE)
installedVersionOfPhenotypeLibrary <- utils::packageDescription(pkg = "PhenotypeLibrary")$Version

description <- readLines("DESCRIPTION")

# Change version number to match PhenotypeLibrary:
versionLineNr <- grep("Version: .*$", description)
packageNumberLineNr <- grep("PhenotypeLibrary .*$", description)
description[versionLineNr] <- sprintf("Version: %s", installedVersionOfPhenotypeLibrary)
description[packageNumberLineNr] <- sprintf("  PhenotypeLibrary (>= %s)", installedVersionOfPhenotypeLibrary)
# Set date:
dateLineNr <- grep("Date: .*$", description)
description[dateLineNr]  <- sprintf("Date: %s", format(Sys.Date(),"%Y-%m-%d"))

writeLines(description, con = "DESCRIPTION")

# Create manual -----------------------------------------------------------------------------
shell("rm extras/PhenotypeLibraryDiagnostics.pdf")
shell("R CMD Rd2pdf ./ --output=extras/PhenotypeLibraryDiagnostics.pdf")

# Store environment in which the study was executed -----------------------
OhdsiRTools::createRenvLockFile(rootPackage = "PhenotypeLibraryDiagnostics",
                                mode = "description",
                                ohdsiGitHubPackages = unique(c(OhdsiRTools::getOhdsiGitHubPackages())),
                                includeRootPackage = FALSE)
