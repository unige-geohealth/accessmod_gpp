import { spawn } from "child_process";
import { promises as fs } from "fs";

//import path from "path";
/*import { fileURLToPath } from "url";*/

/*const __filename = fileURLToPath(import.meta.url);*/
/*const __dirname = path.dirname(__filename);*/

// Helper function to compute travel time
export async function computeTravelTime(location, scenario) {
  try {
    const scenarioArg = JSON.stringify(scenario);

    // Run project_create.R
    //await runRScript("/run/project_create.R", ["--location", location], "/app");

    const tt_args = ["--location", location];

    if (scenarioArg) {
      tt_args.push(...["--scenario", scenarioArg]);
    }

    const result = await runRScript("/run/travel_time.R", tt_args, "/app");
    return result[0];
  } catch (error) {
    console.error("Error running R scripts:", error);
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

