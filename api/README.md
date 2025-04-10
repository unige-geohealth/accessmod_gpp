# AccessMod API

[PROTOTYPE]

This API provides access to AccessMod functionality, allowing users to compute travel times, manage location projects, and more.

## Requirements

- Docker
- Docker Buildx
- Docker Compose (for development)

## Building the Image

The image build requires a buildx context. Use the provided `build.sh` script to build the image:

```bash
./build.sh
```

## Development Environment

The development Docker Compose file is located in `./api/dev`.

To start the development environment:

1. Navigate to the project root
2. Run the start script:

```bash
./start.sh
```

This script prepares the necessary environment variables and starts the Docker Compose services.

## Usage

Once the development environment is running, you can make queries to `localhost:3030`.

Example: Compute Travel Time

```bash
curl -X POST http://localhost:3030/compute_travel_time \
     -H "Content-Type: application/json" \
     -d '{"location": "Madrid", "force": true}'
```

## API Endpoints

- `GET /get_list_locations`: List available locations
- `POST /compute_travel_time`: Compute travel time for a location
- `POST /create_location_project`: Create a new location project

## CLI Usage

The API also supports CLI operations. To use the CLI:

```bash
docker run fredmoser/accessmod_api cli <action> <parameters>
```

Available actions:
- `get_list_locations`
- `travel_time`
- `create` (require a docker socket)

Example:

```bash
docker run fredmoser/accessmod_api cli \
  -v data:/data \
  action=get_list_locations
docker run \
  -v data:/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  fredmoser/accessmod_api  cli \
  action=create_location=Marseille
docker run \
  -v data:/data \
  fredmoser/accessmod_api  cli \
  action=travel_time location=Marseille
```

## Dockerfile

The Dockerfile uses a multi-stage build process:
1. It starts with a base image `fredmoser/accessmod:5.8.3-alpha.2`
2. Installs necessary dependencies
3. Sets up the API environment
4. Configures an entrypoint script to handle both API and CLI operations

## Entrypoint

The entrypoint script (`entrypoint.sh`) handles routing between the main application and CLI operations:
- `app`: Runs the main API server
- `cli`: Runs CLI commands
- Any other command is executed as-is

## Data Persistence

The `/data` directory is set up as a volume for data persistence across container restarts.

## Contributing
TODO
