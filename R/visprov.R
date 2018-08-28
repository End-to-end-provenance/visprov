# A simple tool that allows the user to visualize a provenance
# graph collected by provR or RDataTracker, using DDG Explorer
#

# The port that the DDG Explorer server runs on
ddg.explorer.port <- 6096

# Start the DDG Explorer server.  This should not be called if the
# server is already running.  DDGExplorer.jar must be on .libPaths.
#
# Parameter:  json.path - A file containing json produced by provR.
#
.ddg.start.ddg.explorer <- function (json.path) {
  jar.path <- "/provViz/java/DDGExplorer.jar"
  check.library.paths <- file.exists(paste(.libPaths(), jar.path, sep = ""))
  index <- min(which(check.library.paths == TRUE))
  ddgexplorer_path <- paste(.libPaths()[index], jar.path, sep = "")

  # -s flag starts DDG Explorer as a server.  This allows each new ddg to show
  # up in a new tab of an existing running DDG Explorer.
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
# provR.
ddgexplorer <- function (json.path) {
  # See if the server is already running
  tryCatch ({
    con <- socketConnection(host = "localhost", port = ddg.explorer.port,
                            blocking = FALSE, server = FALSE, open = "w",
                            timeout = 1)

    # Send the filename to DDG Explorer
    writeLines(json.path, con)
    close(con)
  },
  warning = function(e) {
    # The server was not running.  Start it.
    .ddg.start.ddg.explorer(json.path)
  }
  )

  invisible()
}

#' prov.visualize
#' 
#' Display a provenance graph visually.
#'
#' @param r.script.path The path to an R script.  This script will be 
#'         executed with provenance captured by the specified tool.  If r.script.path
#'         is NULL, the last ddg captured will be displayed.
#' @param tool If an R script is passed in, this is the tool that will be used
#'    to collect provenance.  Currently, the known choices are "provR" and 
#'    "RDataTracker", which can be given as "rdt".  If no tool name is passed in,
#'    provR will be used if it is loaded.  If provR is not loaded and RDataTracker
#'    is loaded, RDataTracker will be used.  If neither has been loaded, it then checks
#'    to see if either is installed.  If provR is installed, it will be use.  If 
#'    provR is not installed but RDataTracker is installed, RDataTracker will be
#'    used.  If neither is installed, an error is reported.
#' @param ... If r.script.path is set, these parameters will passed to prov.run to 
#'    collect the provenance.
#' 
#' @export
#' @examples 
#' \dontrun{prov.visualize ()}
#' \dontrun{prov.visualize ("script.R")}
#' \dontrun{prov.visualize ("script.R", tool = "provR")}

prov.visualize <- function (r.script.path = NULL, tool = NULL, ...) {

# Known problems:
#    If the user calls this with NULL for r.script.path but prov.run
#    has not been run yet in the session, there is a json string returned
#    but it is not valid.  prov.json should probably return NULL in
#    that case so we can check that condition.

  # Load the appropriate library
  if (is.null (tool)) {
    loaded <- loadedNamespaces()
    if ("provR" %in% loaded) {
      tool <- "provr"
    }
    else if ("RDataTracker" %in% loaded) {
      tool <- "rdt"
    }
    else {
      installed <- utils::installed.packages ()
      if ("provR" %in% installed) {
        tool <- "provr"
      }
      else if ("RDataTracker" %in% installed) {
        tool <- "rdt"
      }
      else {
        stop ("One of provR or RDataTracker must be installed.")
      }
    }
  }
  else {
    tool <- tolower (tool)
  }
  if (tool == "rdt" || tool == "rdatatracker") {
    prov.vis <- RDataTracker::prov.run
    prov.dir <- RDataTracker::prov.dir
  }
  else {
    if (tool != "provr") {
      print (paste ("Unknown tool: ", tool, "using provR"))
    }
    prov.run <- provR::prov.run
    prov.dir <- provR::prov.dir
  }

  # Run the script, collecting provenance, if a script was provided.
  if (!is.null (r.script.path)) {
    tryCatch (prov.run(r.script.path, ...),
        error = function (e) {})
  }

  # Find out where the provenance is stored.
  json.file <- paste(prov.dir(), "prov.json", sep = "/")
  
  # Display the ddg
  ddgexplorer(json.file)
}
