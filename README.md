# provViz

provViz is a simple tool that allows the user to visualize a provenance
graph collected by rdt or rdtLite using DDG Explorer.  For information on how
to use DDG Explorer, please see the [DDG Explorer README](https://github.com/End-to-end-provenance/DDG-Explorer/blob/master/README.md).

If you have collected provenance in this R session using rdt or rdtLite, you
can view the provenance from the last execution using prov.visualize:

```
prov.visualize()
```

To run a script and view its provenance, call the prov.visualize.run function:
```
prov.visualize.run(r.script.path)
```

If you already have provenance stored in a file, call the prov.visualize.file function:
```
prov.visualize.file(prov.file)
```
where **r.script.path** is the path to an R script and **prov.file** is the name of a file containing provenance.
