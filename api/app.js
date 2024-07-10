import express from "express";
import { getListLocations, computeTravelTime } from "./helpers.js";
import { TifContour } from "./contour.js";
const app = express();
const port = process.env.NODE_ENV === "development" ? 3030 : 3000;

import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.use(express.json());
app.use("/data/location", express.static("/data/location"));

app.get("/data/location/*", (req, res) => {
  const filePath = path.join(__dirname, "data/location", req.params[0]);
  res.sendFile(filePath, (err) => {
    if (err) {
      res.status(404).send(`File not found at ${filePath}`);
    }
  });
});

// GET endpoint to list available locations
app.get("/get_list_locations", async (_, res) => {
  try {
    const locations = await getListLocations();
    res.json(locations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST endpoint to compute travel time
app.post("/compute_travel_time", async (req, res) => {
  const { location, scenario, add_contours } = req.body;

  try {
    const locations = await getListLocations();

    if (!locations.includes(location)) {
      throw new Error(
        `Location ${location} is not yet available, come back later`
      );
    }

    const output = await computeTravelTime(location, scenario);

    if (add_contours) {
      const cc = new TifContour({
        thresholds: output.thresholds,
        raster: output.travel_time,
        proj4: output.proj_4,
      });
      output.contours = await cc.render();
    }

    res.json({
      message: "Travel time computation completed",
      data: output,
    });
  } catch (error) {
    debugger;
    console.error("Error computing travel time:", error);
    res.status(500).json({ error: "Error running AccessMod scripts" });
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
