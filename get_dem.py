import argparse
import os
from time import time

import numpy as np
from osgeo import gdal  # type: ignore
from sardem import cop_dem  # type: ignore

__version__ = "0.2.0"

# Prevent the following warning from being printed to the console:
# FutureWarning: Neither gdal.UseExceptions() nor gdal.DontUseExceptions()
# has been explicitly called. In GDAL 4.0, exceptions will be enabled by
# default.
gdal.UseExceptions()


def logtime(func):
    """Function decorator to log the time (seconds) a function takes to execute."""

    def wrapper(*args, **kwargs):
        start = time()
        result = func(*args, **kwargs)
        print(f"Function {func.__name__} took {time() - start:.1f} seconds")
        return result

    return wrapper


@logtime
def get_dem(bbox: list[float], out_dir: str) -> str:
    """
    Generate a COP DEM Gtiff for a bounding box.

    Parameters
    ----------
    bbox
        lat/lon bounding box, with orientation: left, bottom, right, top.
        Example: [-156, 18.8, -154.7, 20.3]
    out_dir
        Path to an existing directory to write the generated DEM GeoTIFF to.

    Returns
    -------
    dem_file
        Filepath to the generated DEM GeoTIFF.
        In practise, this will be: "<out_dir>/dem.tif"
    """
    dem_file = os.path.join(out_dir, "dem.tif")
    cop_dem.download_and_stitch(dem_file, bbox, output_format="GTiff")

    return dem_file


@logtime
def read_dem_as_array(dem_file: str) -> np.ndarray:
    """Read a DEM file as a numpy array.

    Parameters
    ----------
    dem_file
        Filepath to the DEM GeoTIFF to read.

    Returns
    -------
    dem
        The DEM as a numpy array.
    """
    ds: gdal.Dataset

    with gdal.Open(dem_file) as ds:
        band: gdal.Band = ds.GetRasterBand(1)
        dem: np.ndarray | None = band.ReadAsArray()

    assert dem is not None, "DEM is None"

    return dem


@logtime
def do_computations(dem: np.ndarray) -> None:
    """
    Open the DEM raster and do compute-intensive, multicore computations.

    This function produces no meaningful output, and does NOT
    modify the dem file. What it does is exercise the underlying
    compute nodes by using the maximum number of CPUs allowed by BLAS,
    for an extended period of time, and using a significant amount of memory.

    By default, BLAS uses all available CPUs on a system.  To set this manually,
    set the environment variable ``OPENBLAS_NUM_THREADS`` to the number of
    threads you want to use.

    Parameters
    ----------
    dem
        The DEM as a numpy array.
    """
    print(f"Number of CPU cores available: {os.cpu_count()}")

    # Make sure the array is square so we can compute the multiplicative inverse
    square_dem = (
        dem
        if (min_edge := min(np.shape(dem))) == max(np.shape(dem))
        else dem[:min_edge, :min_edge]
    )

    # Multi-core section
    np.dot(np.linalg.inv(square_dem), square_dem)


def parse_args() -> argparse.Namespace:
    """Parse the command-line arguments."""

    parser = argparse.ArgumentParser()

    parser.add_argument("-v", "--version", action="version", version=__version__)
    parser.add_argument(
        "-c",
        "--compute",
        action=argparse.BooleanOptionalAction,
        help="flag to crunch numbers, exercise multiple cores, and use a LOT of memory",
        default=False,
    )
    parser.add_argument(
        "--bbox",
        type=float,
        help="lat/lon bounding box (example: --bbox -156 18.8 -154.7 20.3)",
        nargs=4,
        metavar=("LEFT", "BOTTOM", "RIGHT", "TOP"),
        required=True,
    )
    parser.add_argument(
        "--output-dir",
        dest="out_dir",
        metavar="PATH",
        type=str,
        help="output directory to write DEM GeoTIFF to",
        required=True,
    )

    return parser.parse_args()


def main():
    """
    Take a bounding box and output a GeoTIFF DEM.

    This is a thin wrapper around `sardem`: https://github.com/scottstanie/sardem

    This script is meant test the MAAP processing pipeline; it is
    hardcoded to fetch the Copernicus DEM from the AWS Open Data registry.
    See: https://registry.opendata.aws/copernicus-dem/

    The code will fetch the necessary DEM tiles, stitch them together with GDAL,
    and create a single geotiff DEM in the `out_dir` directory, named `dem.tif`.

    If the `--compute` flag is included, it will open the generated dem.tif
    file and do compute-intensive, multi-core linear algebra computations
    on that DEM raster. There are no changes made to the dem.tif; this command
    is simply for benchmarking compute.

    Example command-line calls:

        # bounding box: left bottom right top
        python get_dem.py --bbox -156 18.8 -154.7 20.3 --output-dir output

        # --compute will perform intense, multi-core computations
        python get_dem.py --bbox -156 18.8 -154.7 20.3 --compute --output-dir output
    """
    # Step 1: Parse Arguments
    args = parse_args()

    # Step 2: Make dem.tif
    os.makedirs(args.out_dir, exist_ok=True)
    dem_file = get_dem(args.bbox, args.out_dir)

    # Step 3: Perform compute-intensive, multicore operations
    if args.compute:
        do_computations(read_dem_as_array(dem_file))


if __name__ == "__main__":
    main()
