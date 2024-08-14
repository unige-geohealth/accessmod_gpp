import path from "path";
import { spawn } from "child_process";
import { promises as fs } from "fs";
import Docker from "dockerode";
import { PassThrough } from "stream";
import { TifContour } from "./contour.js";
const isDev = process.env.NODE_ENV === "development";
const docker = new Docker({ socketPath: "/var/run/docker.sock" });

export async function computeTravelTimeHandler(
  res,
  location,
  scenario,
  add_contours
) {
  try {
    const locations = await getListLocations();

    if (!locations.includes(location)) {
      throw new Error(
        `Location ${location} is not yet available, come back later or use '/create_location_project'`
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
    res.status(500).json({
      message: `Error /compute_travel_time ${error.message}`,
    });
  }
}

// Helper function to compute travel time
export async function computeTravelTime(location, scenario) {
  try {
    const scenarioArg = JSON.stringify(scenario);

    const tt_args = ["--location", location];

    if (scenarioArg) {
      tt_args.push(...["--scenario", scenarioArg]);
    }

    const result = await runRScript(
      "/04_travel_time/travel_time.R",
      tt_args,
      "/app"
    );
    return result[0];
  } catch (error) {
    console.error("Error during travel time compute:", error);
    throw error;
  }
}

export async function initDB(location) {
  try {
    const result = await runRScript(
      "/04_travel_time/project_create.R",
      ["--location", location],
      "/app"
    );
    return result[0];
  } catch (error) {
    console.error("Error during db init:", error);
    throw error;
  }
}

// Helper function to list locations
export async function getListLocations() {
  try {
    const locationPath = "/data/location";
    const directories = await fs.readdir(locationPath, { withFileTypes: true });
    const locations = directories
      .filter((dirent) => dirent.isDirectory())
      .map((dirent) => dirent.name);
    return locations;
  } catch (error) {
    console.error("Error reading locations:", error);
    throw new Error("Unable to retrieve locations");
  }
}

// Helper function to run R scripts
function runRScript(scriptPath, args, wd) {
  return new Promise((resolve, reject) => {
    const process = spawn("Rscript", [scriptPath, ...args], { cwd: wd });

    let stdout = "";
    let stderr = "";

    process.stdout.on("data", (data) => {
      stdout += data.toString();
    });

    process.stderr.on("data", (data) => {
      stderr += data.toString();
    });

    process.on("close", (code) => {
      if (code !== 0) {
        reject(new Error(`R script exited with code ${code}\n${stderr}`));
      } else {
        const res = stdout.match(/\{(?:[^{}]|"[^"]*"|')*\}/g);

        if (res) {
          return resolve(res.map(JSON.parse));
        }

        resolve([stdout]);
      }
    });
  });
}

export async function createLocationProjectHandler(res, location, force) {
  if (!location) {
    return res.status(400).json({ message: "Location name is required" });
  }

  try {
    const locations = await getListLocations();
    if (locations.includes(location) && !force) {
      return res.status(409).json({
        message:
          "Location project already exists. Use 'force: true' to recreate.",
      });
    }

    if (locations.includes(location) && force) {
      console.log(`Recreating project for ${location}`);
    } else {
      console.log(`Creating new project for ${location}`);
    }

    await createLocationProject(location);
    await computeTravelTime(location);

    const action = force ? "recreated" : "created";
    res.json({ message: `Project for ${location} ${action} successfully` });
  } catch (error) {
    const action = force ? "recreating" : "creating";
    res.status(500).json({
      message: `Error ${action} project for ${location}: ${error.message}`,
    });
  }
}

export async function createLocationProject(location) {
  const steps = [
    "01_get_data",
    "02_build_merged_landcover",
    "03_create_start_points",
  ];

  for (const step of steps) {
    await runStep(step, location);
  }
  await initDB(location);
}

async function runStep(step, location) {
  console.log(`Run step ${step} `);

  const image = "fredmoser/inaccessmod:latest";
  const cmd = ["/bin/sh", "-c", `cd /${step} && Rscript main.R`];

  const binds = [`${bindPath("/data")}:/data:rw`];

  if (isDev) {
    binds.push(
      ...[
        `${bindPath("/helpers")}:/helpers:ro`,
        `${bindPath(step)}:/${step}:ro`,
      ]
    );
  }

  const container = await docker.createContainer({
    Image: image,
    Cmd: cmd,
    Env: [`GPP_LOCATION=${location}`],
    HostConfig: {
      Binds: binds,
    },
  });

  const { res, logs } = await runContainer(container);
  if (!res.StatusCode === 0) {
    const msgLogs = logs.join("\n");
    const msg = [
      `Error during step ${step} for location ${location}`,
      `Logs : ${msgLogs}`,
    ];
    throw new Error(msg.join("\n"));
  }
}

function bindPath(containerPath) {
  // Required to provide the correct context for binds. /proc/self/mountinfo are
  // not usable : docker alters the paths. This is a workaround for dev
  const bind_path = process.env.BIND_PATH;
  console.log("BIND_PATH", bind_path);
  if (!bind_path) {
    return containerPath;
  }
  return path.join(bind_path, containerPath);
}

/**
 * Get logs from running container until it stops
 */
async function runContainer(container) {
  const logStream = new PassThrough();
  const out = {
    logs: [],
    res: {
      StatusCode: null,
    },
  };
  logStream.on("data", (chunk) => {
    const log = chunk.toString("utf8");
    if (log && log.length > 1) {
      out.logs.push(log);
      console.log(log);
    }
  });
  await container.start();
  const stream = await container.logs({
    follow: true,
    stdout: true,
    stderr: true,
  });

  container.modem.demuxStream(stream, logStream, logStream);
  try {
    out.res = await container.wait();
  } catch (err) {
    console.error("Error in containerLogs:", err.message);
  }
  await container.remove();
  stream.destroy();
  logStream.end("Container stopped");
  return out;
}
