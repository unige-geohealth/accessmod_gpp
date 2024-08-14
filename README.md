#AccessMod + GPP

[PROTOTYPE]

## 🌟 Project Overview

This project utilizes AccessMod to compute travel times to various OpenStreetMap (OSM) features, such as green areas, parks, nature reserves, and other leisure spaces. It's designed to assess the accessibility of features, e.g. public green spaces in urban environments.

Developed by the GeoHealth team at the University of Geneva, this tool combines the power of AccessMod's travel time modeling with the extensive feature data available in OpenStreetMap.

Project Repository: [https://github.com/unige-geohealth/accessmod_gpp](https://github.com/unige-geohealth/accessmod_gpp)




## 🔑 Key Features

- 📊 Fetches and processes geospatial data using the inaccessmod package
- ⏱️ Utilizes AccessMod's replay mode for travel time analysis
- 🏙️ Supports analysis for multiple cities
- 🧩 Modular structure for step-by-step data processing and analysis

## 📋 Prerequisites

- 🐳 Docker
- 💻 Bash shell

## 🚀 Installation

1. Clone the repository:

```
git clone https://github.com/unige-geohealth/accessmod_gpp.git
cd accessmod_gpp
```

2. Ensure Docker is installed and running on your system.

## 🔧 Usage

Run the main script:

```
./start.sh
```

This script will guide you through the following steps:

1. Select a city for analysis
2. Choose whether to run in development mode
3. Select which part of the analysis to run:
   - 01_get_data: Fetch required geospatial data
   - 02_build_merged_landcover: Process and merge landcover data
   - 03_create_start_points: Generate starting points for analysis
   - 04_travel_time: Perform travel time calculations using AccessMod

## 📁 Project Structure

- `01_get_data`, `02_build_merged_landcover`, `03_create_start_points`, `04_travel_time`: Contain scripts for different stages of data processing and analysis
- `helpers`: Utility scripts
- `data`: Main data directory, includes subdirectories for each analyzed city


## 🌐 Direct API Access

In addition to using the `./start.sh` script, you can interact directly with the AccessMod API using curl commands or our Docker wrapper.

### 🛠️ Using Direct curl Commands

You can use the following curl commands to interact directly with the AccessMod API:

1. List available locations:
```bash
curl -s -X GET "https://accessmod.mapx.org/get_list_locations" \
     -H "Content-Type: application/json"
```

2. Create location project:
```bash
curl -s -X POST "https://accessmod.mapx.org/create_location_project" \
     -H "Content-Type: application/json" \
     -d '{"location":"Bern"}'
```

3. Compute travel time:
```bash
curl -s -X POST "https://accessmod.mapx.org/compute_travel_time" \
     -H "Content-Type: application/json" \
     -d '{"location":"Bern","scenario":"scenario1"}'
```

Replace "Bern" and "scenario1" with your desired location and scenario (see in assets for a generic scenario).

### 🐳 Using the Docker curl Wrapper

We provide a Docker image that wraps the curl functionality, making it easier to interact with the API in a consistent environment. To use it:

1. Pull the Docker image:
```bash
docker pull fredmoser/accessmod_api_curl
```

2. Run commands using the Docker wrapper:

List available locations:
```bash
docker run --rm fredmoser/accessmod_api_curl --action locations_list
```

Create a location project:
```bash
docker run --rm fredmoser/accessmod_api_curl --action location_create --location Bern
```

Compute travel time:
```bash
docker run --rm fredmoser/accessmod_api_curl --action travel_time --location Bern --scenario scenario1
```

The Docker wrapper provides a convenient way to interact with the API, especially if you're working in an environment where curl might not be readily available or if you want to ensure consistent behavior across different systems.

Note: The Docker wrapper uses a script similar to the one described in the Usage section, but packaged in a Docker container for ease of use and consistency.


## 🔗 Dependencies

- AccessMod (version 5.8.3-alpha.2)
- inaccessmod package (latest version)

## 💻 Development

To enter development mode, select 'y' when prompted "Do you want to develop?". This will give you a bash shell in the Docker container for debugging and development purposes.

## 🤝 Contributing

We welcome contributions to this project. Please feel free to submit issues and pull requests.

## 📄 License

[Insert appropriate license information here]

## 📞 Contact

For more information, please contact the GeoHealth team at the University of Geneva.

## 📊 Sample Results

[dummy model]

Below is a plot showing the Percentage of Population Covered vs Travel Time Zone (in minutes) for three sample cities: Dubai, Milan, and Zurich.

![Population Coverage vs Travel Time](assets/example_comparison_green_access.png)

This plot demonstrates how the percentage of the population with access to green public spaces increases as the travel time increases. It provides a visual comparison of accessibility across different urban environments.

Key observations:
- Zurich and Milan show comparable access to green spaces, with similar curves on the graph.
- Dubai demonstrates significantly less access to green spaces, requiring inhabitants to travel much further to reach these areas.
- The stark difference between Dubai and the European cities highlights how urban planning and geography can impact access to green spaces.

This type of analysis can help urban planners and policymakers understand and improve access to green spaces in their cities.
