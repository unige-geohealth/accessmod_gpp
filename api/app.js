import express from "express";
import cors from "cors";
import {
  getListLocations,
  computeTravelTimeHandler,
  createLocationProjectHandler,
} from "./helpers.js";
const app = express();
const port = process.env.NODE_ENV === "development" ? 3030 : 3000;

import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.use(express.json());
app.use(cors());
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
    res
      .status(500)
      .json({ message: `Error /get_list_locations ${error.message}` });
  }
});

// POST endpoint to compute travel time
app.post("/compute_travel_time", async (req, res) => {
  const { location, scenario, add_contours } = req.body;
  await computeTravelTimeHandler(res, location, scenario, add_contours);
});

app.post("/create_location_project", async (req, res) => {
  const { location, force } = req.body;
  await createLocationProjectHandler(res, location, force);
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
