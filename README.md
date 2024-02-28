# Get DEM

Take a bounding box and output a GeoTIFF DEM, optionally performing intense,
multi-core computations on it.

## Introduction

This is a thin wrapper around `sardem`: <https://github.com/scottstanie/sardem>

The wrapper is designed for use with the MAAP project.  It is meant to exercise
the MAAP processing pipeline.

The source DEM is hardcoded to be the Copernicus DEM, which is fetched from the
AWS Open Data registry.  See: <https://registry.opendata.aws/copernicus-dem/>

The code will fetch the necessary DEM tiles, stitch them together with GDAL, and
create a single GeoTIFF DEM, named `dem.tif`, in the output directory.

If the `--compute` flag is included, it will open the generated file and do
compute-intensive, multi-core linear algebra computations on that DEM raster.
There are no changes made to the file; this command is simply for benchmarking
compute.  These computations use NumPy's linear algebra module, which uses all
available CPU cores.

Example command-line calls:

```plain
# bounding box: left bottom right top
python get_dem.py --bbox -156 18.8 -154.7 20.3 --output-dir output

# --compute is a flag to have the compute node perform intense, multi-core computations
python get_dem.py --bbox -156 18.8 -154.7 20.3 --compute --output-dir output
```
