library (provR)
library (CamFlow)

# A simple tool that allows the user to visualize a provenance
# graph collected by provR, using either DDG Explorer or
# Cam View.
#
# Author: Barbara Lerner
# Date: October 18, 2017

# The port that the DDG Explorer server runs on
ddg.explorer.port <- 6096

# Start the DDG Explorer server.  This should not be called if the
# server is already running.  DDGExplorer.jar must be on .libPaths.
#
# Parameter:  json.path - A file containing json produced by provR.
#
# Known problems:  Currently, it looks inside the RDataTracker package
#   for DDGExplorer.jar.  This would need to be changed so that the 
#   visprov package contained the jar file if visprov is turned into 
#   a package.
#
.ddg.start.ddg.explorer <- function (json.path) {
  jar.path<- "/RDataTracker/java/DDGExplorer.jar"
  check.library.paths<- file.exists(paste(.libPaths(),jar.path,sep = ""))
  index<- min(which(check.library.paths == TRUE))
  ddgexplorer_path<- paste(.libPaths()[index],jar.path,sep = "")
  
  # -s flag starts DDG Explorer as a server.  This allows each new ddg to show
  # up in a new tab of an existing running DDG Explorer.
  systemResult <- system2("java", c("-jar", ddgexplorer_path, json.path, "-port", ddg.explorer.port), wait = FALSE)
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
    con <- socketConnection(host= "localhost", port = ddg.explorer.port, blocking = FALSE,
                            server=FALSE, open="w", timeout=1)

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

# Display a DDG created by provR visually.
#
# Parameters:
#    json.path - the path to a prov json file created by provR
#    visualizer - which visualizer to run.  Possible values are
#        ddgexplorer or camview.  The default is ddgexplorer.
ddg.display <- function (json.path, visualizer="ddgexplorer") {
  if (visualizer == "camview") {
    CamFlowVisualiser(json.path)
  }
  
  else if (visualizer == "ddgexplorer")  {
    ddgexplorer(json.path)
  }
  
  else {
    print ("Unknown visualizer")
  }
}

# This is the only function that would be exported.  It displays a 
# DDG visually.
#
# Parameters:
#    r.script.path - The path to an R script.  This script will be 
#         executed with provenance captured by provR.  If r.script.path
#         is NULL, the last ddg captured will be displayed.
#    visualizer - which visualizer to use.  Possible values are "ddgexplorer"
#         or "camview".
#
# Known problems:
#    If the user calls this with NULL for r.script.path but prov.capture
#    has not been run yet in the session, there is a json string returned
#    but it is not valid.  prov.json should probably return NULL in t
#    that case so we can check that condition.
prov.visualize <- function (r.script.path = NULL, visualizer = "ddgexplorer") {
  # Run the script, collecting provenance, if a script was provided.
  if (!is.null (r.script.path)) {
    prov.capture(r.script.path)
  }
  
  # Write the json to a file
  ddgjson.path<- paste(getwd(), ".ddg.json",sep = "/")
  writeLines (prov.json(), ddgjson.path)
  
  # Display the ddg
  ddg.display (ddgjson.path, visualizer)
}

