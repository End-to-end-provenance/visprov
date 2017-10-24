# visprov

visprov is a simple tool that allows the user to visualize a provenance
graph collected by provR, using either DDG Explorer or
Cam View.

To use it, call the prov.visualize function:
```
prov.visualize <- function (r.script.path = NULL, visualizer = "ddgexplorer")
```

## Parameters
**r.script.path** - The path to an R script.  This script will be 
executed with provenance captured by provR.  If r.script.path
is NULL, the last ddg captured will be displayed.

**visualizer** - which visualizer to use.  Possible values are "ddgexplorer"
or "camview".

## Known problems
If the user calls this with NULL for r.script.path but prov.capture
has not been run yet in the session, there is a json string returned
but it is not valid.  prov.json should probably return NULL in 
that case so prov.visualize can check that condition.

This function currently requires that RDataTracker be installed so that it can
find the DDGExplorer.jar file.  Obviously, if this were actually incorporated into
a package and included in the provTools suite, we would change this.

