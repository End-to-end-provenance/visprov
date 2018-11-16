# provViz

provViz is a simple tool that allows the user to visualize a provenance
graph collected by rdt or rdtLite using DDG Explorer.  For information on how
to use DDG Explorer, please see the [DDG Explorer README](https://github.com/End-to-end-provenance/DDG-Explorer/blob/master/README.md).

If you have collected provenance in this R session using rdt or rdtLite, you
can view the provenance from the last execution using prov.visualize:

```
prov.visualize()
```

To run a script and view its provenance, call the prov.visualize function:
```
prov.visualize (r.script.path = NULL, tool = "rdtLite")
```

If you already have provenance stored in a file, call the prov.visualize.saved function:
```
prov.visualize.saved (prov.file)
```


**r.script.path** - The path to an R script.  This script will be 
executed with provenance captured by rdt or rdtLite.  If r.script.path
is NULL, the last provenance graph captured will be displayed.

**tool** - which tool to use to capture proveannce.  Possible values are "rdtLite" or "rdt".

**prov.file** - The name of a file containing provenance.

## Known problems
If the user calls this with NULL for r.script.path but no provenance
has been captured yet in the session, there is a json string returned
but it is not valid.
