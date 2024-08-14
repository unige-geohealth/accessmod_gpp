import {
  getListLocations,
  computeTravelTime,
  createLocationProject,
} from "./helpers.js";

// Parse command-line arguments
const args = process.argv.slice(2);
const params = {};

args.forEach((arg) => {
  const [key, value] = arg.split("=");
  params[key] = value;
});

// Function to handle CLI response
const handleCliResponse = (error, result) => {
  if (error) {
    console.error("Error:", error.message);
    process.exit(1);
  }
  try {
    console.log(JSON.stringify(result, null, 2));
  } catch (e) {
    console.log(result);
  }
  process.exit(0);
};

// Main CLI logic
async function main() {
  const { location, scenario, action, add_contours } = params;

  const locations = await getListLocations();
  try {
    switch (action) {
      case "get_list_locations":
        handleCliResponse(null, locations);
        break;

      case "travel_time":
        if (!location || !scenario) {
          throw new Error(
            "Location and scenario are required for travel_time action"
          );
        }

        if (!locations.includes(location)) {
          console.log("Missing location, compute that first");
          await createLocationProject(location);
        }

        const scenarioParsed = JSON.parse(scenario);

        const travelTimeResult = await computeTravelTime(
          location,
          scenarioParsed
        );

        if (add_contours === "true") {
          console.warn(
            "Contour generation is not implemented in this CLI version"
          );
        }
        handleCliResponse(null, travelTimeResult);
        break;

      case "create":
        if (!location) {
          throw new Error("Location is required for create action");
        }
        await createLocationProject(location);
        handleCliResponse(null, {
          message: `Project for ${location} created successfully`,
        });
        break;

      default:
        throw new Error(`Unknown action: ${action}`);
    }
  } catch (error) {
    handleCliResponse(error);
  }
}

main();
