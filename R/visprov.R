# Copyright (C) President and Fellows of Harvard College and 
# Trustees of Mount Holyoke College, 2018.

# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program.  If not, see
#   <http://www.gnu.org/licenses/>.

# A simple tool that allows the user to visualize a provenance
# graph collected by rdt or rdtLite, using DDG Explorer
#

# The port that the DDG Explorer server runs on
ddg.explorer.port <- 6096

# Start the DDG Explorer server.  This should not be called if the
# server is already running.  DDGExplorer.jar must be on .libPaths.
#
# Parameter:  json.path - A file containing json produced by rdt or rdtLite.
#
.ddg.start.ddg.explorer <- function (json.path) {
  # Quote the json.path so that if there are embedded spaces it will still
  # be passed as one string
  json.path <- paste0 ("\"", json.path, "\"")
  
  jar.path <- "/provViz/java/DDGExplorer.jar"
  check.library.paths <- file.exists(paste(.libPaths(), jar.path, sep = ""))
  index <- min(which(check.library.paths == TRUE))
  ddgexplorer_path <- paste(.libPaths()[index], jar.path, sep = "")

  # Start DDG Explorer as a server
  systemResult <- system2("java",
      c("-jar", ddgexplorer_path, json.path, "-port", ddg.explorer.port),
      wait = FALSE)
  if (systemResult != 0) {
    warning ("Unable to start DDG Explorer to display the provenance graph.")
  }
}

# Loads a prov json file into DDG Explorer.  If DDG Explorer is not
# already running, it starts it.  If it is running, a new panel
# will appear containing the new DDG.
#
# Parameter:  json.path - the path to a prov json file created by
# rdt or rdtLite.
ddgexplorer <- function (json.path) {
  print (paste ("Reading json from ", json.path))

  # See if the server is already running
  tryCatch ({
    con <- socketConnection(host = "localhost", port = ddg.explorer.port,
                            blocking = FALSE, server = FALSE, open = "w",
                            timeout = 1)

    # Send the filename to DDG Explorer
    print ("Connecting to DDG Explorer")
    writeLines(json.path, con)
    close(con)
  },
  warning = function(e) {
    # The server was not running.  Start it.
    print ("Starting DDG Explorer")
    .ddg.start.ddg.explorer(json.path)
  }
  )

  invisible()
}

#' prov.visualize
#' 
#' prov.visualize displays the provenance graph for the last provenance
#' collected in this R session.
#' 
#' These functions use provenance collected using the rdtLite or rdt packages.
#' 
#' These functions do nothing when called non-interactively.
#'
#' @export
#' @examples 
#' \dontrun{prov.visualize ()}
#' @rdname prov.visualize

prov.visualize <- function () {
  if (!interactive()) {
    return()
  }

  # Load the appropriate library
  loaded <- loadedNamespaces()
  if ("rdtLite" %in% loaded) {
    tool <- "rdtLite"
  }
  else if ("rdt" %in% loaded) {
    tool <- "rdt"
  }
  else {
    installed <- utils::installed.packages ()
    if ("rdtLite" %in% installed) {
      tool <- "rdtLite"
    }
    else if ("rdt" %in% installed) {
      tool <- "rdt"
    }
    else {
      stop ("One of rdtLite or rdt must be installed.")
    }
  }

  if (tool == "rdt") {
    prov.dir <- rdt::prov.dir
  }
  else {
    prov.dir <- rdtLite::prov.dir
  }

  # Find out where the provenance is stored.
  provDir <- path.expand(prov.dir())
  if (!is.null (provDir)) {
    json.file <- paste(provDir, "prov.json", sep = "/")

    # Display the ddg
    ddgexplorer(json.file)
  }
  else {
    print ("No provenance has been collected yet.  Try prov.visualize.run (r.script.path).")
  }

}

#' prov.visualize.file
#' 
#' prov.visualize.file displays provenance stored in a file graphically
#' 
#' @param prov.file the name of a file containing provenance that has been
#'    created by rdt or rdtLite, or another tool producing compatible
#'    provenance output.
#' 
#' @export
#' @examples 
#' testdata <- system.file("testdata", "prov.json", package = "provViz")
#' prov.visualize.file (testdata)
#' @rdname prov.visualize
prov.visualize.file <- function (prov.file) {
  if (!interactive()) {
    return()
  }
  
  ddgexplorer(prov.file)
}

#' prov.visualize.run
#' 
#' prov.visualize.run runs an R script and displays its provenance graph visually.
#'
#' @param r.script.path The path to an R script.  This script will be 
#'         executed with provenance captured by the specified tool.
#' @param ... If r.script.path is set, these parameters will be passed to prov.run to 
#'    control how provenance is collected.  
#'    See rdt's prov.run function
#'    or rdtLites's prov.run function for details.
#' 
#' @export
#' @examples 
#' \dontrun{prov.visualize.run ("script.R")}
#' \dontrun{prov.visualize.run ("script.R", tool = "rdtLite")}
#' @rdname prov.visualize
prov.visualize.run <- function (r.script.path,  ...) {
  if (!interactive()) {
    return()
  }
  
  # Load the appropriate library
  loaded <- loadedNamespaces()
  if ("rdtLite" %in% loaded) {
    tool <- "rdtLite"
  }
  else if ("rdt" %in% loaded) {
    tool <- "rdt"
  }
  else {
    installed <- utils::installed.packages ()
    if ("rdtLite" %in% installed) {
      tool <- "rdtLite"
    }
    else if ("rdt" %in% installed) {
      tool <- "rdt"
    }
    else {
      stop ("One of rdtLite or rdt must be installed.")
    }
  }

  if (tool == "rdt") {
    prov.run <- rdt::prov.run
    prov.dir <- rdt::prov.dir
  }
  else {
    if (tool != "rdtLite") {
      print (paste ("Unknown tool: ", tool, "using rdtLite"))
    }
    prov.run <- rdtLite::prov.run
    prov.dir <- rdtLite::prov.dir
  }

  # Run the script, collecting provenance, if a script was provided.
  tryCatch (prov.run(r.script.path, ...),
      error = function (e) {})

  # Find out where the provenance is stored.
  json.file <- paste(prov.dir(), "prov.json", sep = "/")

  # Display the ddg
  ddgexplorer(json.file)
}
