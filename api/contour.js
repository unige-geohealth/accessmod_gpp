import { contours } from "d3-contour";
import { fromArrayBuffer } from "geotiff";
import proj4 from "proj4";
import { promises as fs } from "fs";

const def = {
  proj4: null,
  raster: null,
  thresholds: [],
};

class TifContour {
  constructor(config) {
    this._config = Object.assign({}, def, config);
    this._w = 0;
    this._h = 0;
    this._xMin = 0;
    this._xMax = 0;
    this._yMin = 0;
    this._yMax = 0;
    this._res = [0, 0];
  }

  get proj4() {
    return this._config.proj4;
  }

  get raster() {
    return this._config.raster;
  }
  get thresholds() {
    return this._config.thresholds;
  }

  toArrayBuffer(buf) {
    const ab = new ArrayBuffer(buf.length);
    const view = new Uint8Array(ab);
    for (var i = 0; i < buf.length; ++i) {
      view[i] = buf[i];
    }
    return ab;
  }

  async render() {
    const exists = await fileExists(this.raster);
    if (!exists) {
      throw new Error(`File ${this.raster} not found`);
    }
    const tiffBuff = await fs.readFile(this.raster);
    const tiffABuff = this.toArrayBuffer(tiffBuff);
    const tiff = await fromArrayBuffer(tiffABuff);
    const img = await tiff.getImage();
    const values = (await img.readRasters())[0];
    const bbox = img.getBoundingBox();

    this._xMin = bbox[0];
    this._yMin = bbox[1];
    this._xMax = bbox[2];
    this._yMax = bbox[3];

    this._res = img.getResolution();
    this._res_y = Math.abs(this._res[1]);
    this._res_x = Math.abs(this._res[0]);
    this._w = img.getWidth();
    this._h = img.getHeight();

    this._dx = this._xMax - this._xMin;
    this._dy = this._yMax - this._yMin;

    const contoursGenerator = contours()
      .size([this._w, this._h])
      .smooth(true)
      .thresholds(this.thresholds);

    const geoms = contoursGenerator(values);
    const features = geoms.map((geom, i) =>
      this.createFeature(geom, this.thresholds[i])
    );
    return {
      type: "FeatureCollection",
      features: features,
    };
  }

  createFeature(geom, threshold) {
    const coords = geom.coordinates.map((group) =>
      group.map((coord) =>
        coord.map((c) => this.reprojectPoint(this.pixToCoord(c[0], c[1])))
      )
    );

    return {
      type: "Feature",
      properties: { value: threshold },
      geometry: { ...geom, coordinates: coords },
    };
  }

  pixToCoord(x, y) {
    const lng = x * this._res_x + this._xMin;
    const lat = this._yMax - y * this._res_y; // Adjusted to start from _yMax
    return [lng, lat];
  }

  reprojectPoint(point) {
    return proj4(this.proj4, "EPSG:4326", point);
  }
}

export { TifContour };

async function fileExists(filePath) {
  try {
    await fs.access(filePath);
    return true; // File exists
  } catch (error) {
    if (error.code === "ENOENT") {
      return false; // File does not exist
    } else {
      throw error; // An unexpected error occurred
    }
  }
}
