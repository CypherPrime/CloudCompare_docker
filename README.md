# CloudCompare Docker Setup

This Docker image provides CloudCompare running in a headless environment with web access via noVNC. Perfect for point cloud processing, visualization, and batch operations.

## What's Included

- **CloudCompare**: Latest version built from source with full dependencies
- **VNC Server**: Remote desktop access via X11VNC
- **noVNC**: Web-based VNC viewer accessible from any browser
- **Xvfb**: Virtual framebuffer for headless operation
- **Fluxbox**: Lightweight window manager
- **XTerm**: Terminal for CLI commands
- **Qt6**: Modern Qt6 framework support
- **LASzip**: Support for LAS/LAZ point cloud formats

## Prerequisites

- Docker installed and running
- At least 8GB of free disk space for the image
- Port 6080 available for noVNC access
- Ubuntu 24.04 base image (for Qt 6.4+ support)

## Building the Image

### Standard Build

```bash
cd CloudCompare
docker build -t cloudcompare:latest .
```

### Build with Custom Tag

```bash
docker build -t myregistry/cloudcompare:1.0 .
```

### Build Without Cache (Full Rebuild)

```bash
docker build --no-cache -t cloudcompare:latest .
```

Build time: Approximately 5-15 minutes depending on your system.

## Running the Container

### Mode 1: GUI Access via Web Browser (Recommended)

Start with CloudCompare **auto-launching** on startup:

```bash
docker run -d \
  -p 6080:6080 \
  -e RUN_CLOUDCOMPARE=1 \
  --name cloudcompare-vnc \
  cloudcompare:latest \
  /usr/local/bin/start_vnc.sh
```

Access at: **http://localhost:6080**

### Mode 2: Manual Launch (GUI without Auto-start)

Start without auto-launching CloudCompare:

```bash
docker run -d \
  -p 6080:6080 \
  --name cloudcompare-vnc \
  cloudcompare:latest \
  /usr/local/bin/start_vnc.sh
```

Then:
1. Open **http://localhost:6080** in your browser
2. Click inside the xterm window
3. Type: `CloudCompare`
4. Press Enter

### Mode 3: With Local Data Directory Mounted

Mount your point cloud files for easy access:

```bash
docker run -d \
  -p 6080:6080 \
  -v /path/to/your/pointclouds:/data \
  -e RUN_CLOUDCOMPARE=1 \
  --name cloudcompare-vnc \
  cloudcompare:latest \
  /usr/local/bin/start_vnc.sh
```

Replace `/path/to/your/pointclouds` with your actual directory path.

Files will be accessible in CloudCompare at `/data/`

### Mode 4: Batch/Headless Processing

Run CloudCompare in batch mode for automated processing:

```bash
docker run -d \
  -v /path/to/your/data:/data \
  -v /path/to/output:/output \
  -e HEADLESS_MODE=1 \
  -e CC_BATCH_SCRIPT=/data/process.ccscript \
  --name cloudcompare-batch \
  cloudcompare:latest \
  /usr/local/bin/start_vnc.sh
```

Or run a direct command:

```bash
docker run --rm \
  -v /path/to/your/data:/data \
  cloudcompare:latest \
  CloudCompare -SILENT -AUTO_SAVE OFF -O /data/input.las -SS SPATIAL 0.1 -SAVE_CLOUDS FILE /data/output.las
```

## Container Management

### Check Container Status

```bash
docker ps -a | grep cloudcompare
```

### View Container Logs

```bash
docker logs cloudcompare-vnc
```

### Stop the Container

```bash
docker stop cloudcompare-vnc
```

### Start the Container

```bash
docker start cloudcompare-vnc
```

### Restart the Container

```bash
docker restart cloudcompare-vnc
```

### Remove the Container

```bash
docker rm cloudcompare-vnc
```

### Access Container Shell

```bash
docker exec -it cloudcompare-vnc bash
```

## CloudCompare Commands

### GUI Mode

Once in the web interface (http://localhost:6080), you can launch CloudCompare from the xterm:

```bash
# Launch GUI
CloudCompare

# Open specific file
CloudCompare -O /data/myfile.las

# Open multiple files
CloudCompare -O /data/file1.las -O /data/file2.ply
```

### Command Line Mode

Process point clouds directly from terminal:

```bash
# Subsample point cloud
docker exec cloudcompare-vnc CloudCompare -SILENT -AUTO_SAVE OFF \
  -O /data/input.las -SS SPATIAL 0.1 -SAVE_CLOUDS FILE /data/output.las

# Compute normals
docker exec cloudcompare-vnc CloudCompare -SILENT -AUTO_SAVE OFF \
  -O /data/input.las -COMPUTE_NORMALS -SAVE_CLOUDS FILE /data/output_normals.las

# Convert formats
docker exec cloudcompare-vnc CloudCompare -SILENT -AUTO_SAVE OFF \
  -O /data/input.las -SAVE_CLOUDS FILE /data/output.ply
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RUN_CLOUDCOMPARE` | `0` | Set to `1` to auto-launch CloudCompare GUI on startup |
| `HEADLESS_MODE` | `0` | Set to `1` for batch processing without GUI |
| `CC_BATCH_SCRIPT` | - | Path to CloudCompare batch script for headless mode |
| `DISPLAY` | `:1` | X11 display number |

## Ports

| Port | Service | Description |
|------|---------|-------------|
| `6080` | noVNC | Web-based VNC access |
| `5900` | VNC | Direct VNC connection (not exposed by default) |

## Data Persistence

### Using Volume Mounts

```bash
# Create a data directory
mkdir -p ~/cloudcompare-data

# Run with persistent storage
docker run -d \
  -p 6080:6080 \
  -v ~/cloudcompare-data:/data \
  -e RUN_CLOUDCOMPARE=1 \
  --name cloudcompare-vnc \
  cloudcompare:latest \
  /usr/local/bin/start_vnc.sh
```

### Using Named Volumes

```bash
# Create named volume
docker volume create cloudcompare-data

# Run with named volume
docker run -d \
  -p 6080:6080 \
  -v cloudcompare-data:/data \
  -e RUN_CLOUDCOMPARE=1 \
  --name cloudcompare-vnc \
  cloudcompare:latest \
  /usr/local/bin/start_vnc.sh
```

## Advanced Usage

### Multiple Data Directories

```bash
docker run -d \
  -p 6080:6080 \
  -v ~/input:/data/input:ro \
  -v ~/output:/data/output \
  -v ~/temp:/data/temp \
  -e RUN_CLOUDCOMPARE=1 \
  --name cloudcompare-vnc \
  cloudcompare:latest \
  /usr/local/bin/start_vnc.sh
```

### Custom Display Resolution

Edit `start_vnc.sh` before building to change resolution:

```bash
XVFB_W=1920  # Width
XVFB_H=1080  # Height
XVFB_D=24    # Color depth
```

### Running Multiple Instances

```bash
# First instance on port 6080
docker run -d -p 6080:6080 --name cloudcompare-1 cloudcompare:latest /usr/local/bin/start_vnc.sh

# Second instance on port 6081
docker run -d -p 6081:6080 --name cloudcompare-2 cloudcompare:latest /usr/local/bin/start_vnc.sh
```

Access:
- Instance 1: http://localhost:6080
- Instance 2: http://localhost:6081

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs cloudcompare-vnc

# Check if port is already in use
sudo lsof -i :6080

# Remove and recreate
docker rm cloudcompare-vnc
docker run -d -p 6080:6080 --name cloudcompare-vnc cloudcompare:latest /usr/local/bin/start_vnc.sh
```

### CloudCompare Not Launching

1. **Check if auto-launch is enabled:**
   ```bash
   docker inspect cloudcompare-vnc | grep RUN_CLOUDCOMPARE
   ```

2. **Launch manually:**
   - Open http://localhost:6080
   - Click in xterm window
   - Type: `CloudCompare`

3. **Check CloudCompare installation:**
   ```bash
   docker exec cloudcompare-vnc which CloudCompare
   docker exec cloudcompare-vnc CloudCompare --version
   ```

### Can't Access Web Interface

1. **Check container is running:**
   ```bash
   docker ps | grep cloudcompare
   ```

2. **Check port binding:**
   ```bash
   docker port cloudcompare-vnc
   ```

3. **Test from inside container:**
   ```bash
   docker exec cloudcompare-vnc curl http://localhost:6080
   ```

### Performance Issues

1. **Increase Docker resources** (Docker Desktop settings)
   - Memory: At least 4GB
   - CPUs: 2+ cores

2. **Reduce display resolution** in `start_vnc.sh`

3. **Disable X11 damage detection:**
   Edit `start_vnc.sh` and add `-noxdamage` to x11vnc command

## Supported File Formats

CloudCompare supports numerous point cloud and mesh formats:

### Point Cloud Formats
- LAS/LAZ (LASzip)
- E57
- PLY
- PCD
- XYZ/ASC
- PTX
- BIN
- PTS
- CSV

### Mesh Formats
- OBJ
- STL
- PLY
- FBX
- OFF
- MA (Mascaret)

### Raster Formats
- GeoTIFF
- ASCII Grid
- Image formats (PNG, JPG, etc.)

## Build Information

### System Requirements for Building

- Docker with BuildKit support
- 8GB+ RAM
- 10GB+ free disk space
- Internet connection for package downloads

### Build Fixes Applied

This Dockerfile includes fixes for common CloudCompare build issues:

1. ✅ Replaced deprecated `liblas-dev` with `liblaszip-dev`
2. ✅ Upgraded to Qt6 packages (CloudCompare requires Qt 6.4+)
3. ✅ Installed CMake 3.23+ from Kitware repository
4. ✅ Added `--recursive` flag to fetch CCCoreLib submodule
5. ✅ Using Ubuntu 24.04 for Qt 6.4+ support
6. ✅ Fixed `libgl1-mesa-glx` → `libgl1` for Ubuntu 24.04

## Examples

### Example 1: Basic Visualization

```bash
# Start container with data mount
docker run -d -p 6080:6080 -v ~/pointclouds:/data -e RUN_CLOUDCOMPARE=1 --name cloudcompare-vnc cloudcompare:latest /usr/local/bin/start_vnc.sh

# Access at http://localhost:6080
# File > Open > /data/yourfile.las
```

### Example 2: Batch Processing

```bash
# Create processing script
cat > process.sh << 'EOF'
#!/bin/bash
for file in /data/input/*.las; do
  basename=$(basename "$file" .las)
  CloudCompare -SILENT -AUTO_SAVE OFF \
    -O "$file" \
    -SS SPATIAL 0.1 \
    -SAVE_CLOUDS FILE "/data/output/${basename}_subsampled.las"
done
EOF

# Run batch processing
docker run --rm \
  -v ~/input:/data/input \
  -v ~/output:/data/output \
  cloudcompare:latest \
  bash /data/input/process.sh
```

### Example 3: Format Conversion

```bash
docker run --rm \
  -v ~/data:/data \
  cloudcompare:latest \
  CloudCompare -SILENT -AUTO_SAVE OFF \
    -O /data/input.las \
    -SAVE_CLOUDS FILE /data/output.ply
```

## License

CloudCompare is released under the GNU GPL v2.0 license.

## Resources

- [CloudCompare Official Website](https://www.cloudcompare.org/)
- [CloudCompare GitHub](https://github.com/CloudCompare/CloudCompare)
- [CloudCompare Documentation](https://www.cloudcompare.org/doc/)
- [Command Line Documentation](https://www.cloudcompare.org/doc/wiki/index.php/Command_line_mode)

## Support

For issues with:
- **This Docker image**: Open an issue in this repository
- **CloudCompare itself**: Visit [CloudCompare GitHub Issues](https://github.com/CloudCompare/CloudCompare/issues)
- **Docker**: Visit [Docker Documentation](https://docs.docker.com/)

## Quick Reference Card

```bash
# Build
docker build -t cloudcompare:latest .

# Run (GUI with auto-launch)
docker run -d -p 6080:6080 -e RUN_CLOUDCOMPARE=1 --name cloudcompare-vnc cloudcompare:latest /usr/local/bin/start_vnc.sh

# Access
http://localhost:6080

# Stop
docker stop cloudcompare-vnc

# Start again
docker start cloudcompare-vnc

# View logs
docker logs cloudcompare-vnc

# Remove
docker stop cloudcompare-vnc && docker rm cloudcompare-vnc
```

```bash
docker run -it \
  -p 6080:6080 \
  -v /path/to/data:/data \
  --name cloudcompare \
  cloudcompare:latest
```

Access via browser, then open xterm to run commands like:
- `CloudCompare -O /data/file.las`
- `CloudCompare -O /data/file.laz -C_EXPORT_FMT LAS`
- `CloudCompare -BATCH -AUTO_EXIT -O /data/file.ply`

### Multiple Data Directories

```bash
docker run -it \
  -p 6080:6080 \
  -v /path/to/input:/input \
  -v /path/to/output:/output \
  -v /path/to/scripts:/scripts \
  --name cloudcompare \
  cloudcompare:latest
```

### Running with GPU Support (NVIDIA)

```bash
docker run -it \
  -p 6080:6080 \
  -v /path/to/data:/data \
  --gpus all \
  --name cloudcompare \
  cloudcompare:latest
```

### Custom Port Mapping

```bash
docker run -it \
  -p 8080:6080 \
  -v /path/to/data:/data \
  --name cloudcompare \
  cloudcompare:latest
```

Then access at: **http://localhost:8080**

### Background Mode

```bash
docker run -d \
  -p 6080:6080 \
  -v /path/to/data:/data \
  --name cloudcompare \
  cloudcompare:latest
```

Check logs:
```bash
docker logs -f cloudcompare
```

## Common CloudCompare Commands

### Open Files
```bash
# Single file
CloudCompare -O /data/file.las

# Multiple files
CloudCompare -O /data/*.laz

# Specific formats
CloudCompare -O /data/points.ply /data/mesh.obj
```

### Export/Convert
```bash
# Convert LAS to LAZ
CloudCompare -O file.las -C_EXPORT_FMT LAZ

# Export as XYZ
CloudCompare -O file.las -C_EXPORT_FMT XYZ

# Export as PLY
CloudCompare -O file.las -C_EXPORT_FMT PLY
```

### Batch Processing
```bash
# Silent batch mode
CloudCompare -BATCH -SILENT -O /data/input.las

# Batch with auto-exit
CloudCompare -BATCH -AUTO_EXIT -O /data/cloud.ply

# Run with script
CloudCompare -BATCH -SILENT -SCRIPT /data/script.ccscript
```

### Subsampling/Filtering
```bash
CloudCompare -O /data/large_cloud.las -SS SPATIAL 0.01
```

## Supported Point Cloud Formats

- **LAS/LAZ** - Standard point cloud format
- **PCD** - Point Cloud Data format
- **PLY** - Polygon File Format
- **XYZ** - Simple XYZ ASCII format
- **OBJ** - Wavefront OBJ mesh format
- **STL** - Stereolithography format
- **E57** - 3D imaging data exchange format
- **PTX** - Leica point cloud format
- **IFC** - Building Information Modeling
- And many more...

## Environment Variables

| Variable | Values | Description |
|----------|--------|-------------|
| `RUN_CLOUDCOMPARE` | `0` (default), `1` | Auto-launch CloudCompare GUI on startup |
| `HEADLESS_MODE` | `0` (default), `1` | Enable headless batch processing mode |
| `CC_BATCH_SCRIPT` | Path to `.ccscript` | Script file for batch processing |
| `DISPLAY` | `:1` (default) | X11 display number |

## Display Settings

Virtual display resolution can be modified in `start_vnc.sh`:
```bash
XVFB_W=1280  # Width
XVFB_H=800   # Height
XVFB_D=24    # Color depth
```

For higher resolution:
```bash
XVFB_W=1920
XVFB_H=1080
XVFB_D=24
```

## Docker Compose Example

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  cloudcompare:
    build:
      context: .
      dockerfile: Dockerfile
    image: cloudcompare:latest
    container_name: cloudcompare
    ports:
      - "6080:6080"
    volumes:
      - ./data:/data
      - ./output:/output
    environment:
      - RUN_CLOUDCOMPARE=1
      - TZ=Africa/Douala
    stdin_open: true
    tty: true
    restart: unless-stopped
```

Run with Compose:
```bash
docker-compose up -d
docker-compose logs -f
```

## Managing Containers

### List running containers
```bash
docker ps
```

### Stop container
```bash
docker stop cloudcompare
```

### Start existing container
```bash
docker start cloudcompare
```

### Remove container
```bash
docker rm cloudcompare
```

### View logs
```bash
docker logs cloudcompare
docker logs -f cloudcompare  # Follow logs
```

### Execute command in running container
```bash
docker exec -it cloudcompare bash
```

### Copy files to/from container
```bash
# Copy to container
docker cp /local/path/file.las cloudcompare:/data/

# Copy from container
docker cp cloudcompare:/output/result.laz /local/path/
```

## Troubleshooting

### VNC Connection Issues
- Ensure port 6080 is not blocked by firewall
- Check if container is running: `docker ps`
- View logs: `docker logs cloudcompare`

### CloudCompare Won't Launch
- Check if X11 display is available: `echo $DISPLAY` in xterm
- Verify CloudCompare installation: `which CloudCompare`
- Check permissions on mounted volumes

### Memory Issues
- Increase Docker memory allocation
- Use subsampling for large point clouds
- Process in batch with smaller chunks

### File Permission Errors
- Ensure mounted directory is readable: `chmod -R 755 /path/to/data`
- Run container with appropriate user ID

### Performance Issues
- Use GPU support for better performance
- Reduce virtual display resolution
- Increase available resources to Docker

## Performance Optimization

### For Large Point Clouds
1. Use headless batch mode instead of GUI
2. Enable GPU acceleration (`--gpus all`)
3. Subsample or filter before processing
4. Use LAZ format for compression

### For Better UI Responsiveness
1. Increase virtual display resolution
2. Allocate more CPU cores
3. Use SSD for docker storage

## Additional Resources

- [CloudCompare Official Website](https://www.cloudcompare.org/)
- [CloudCompare GitHub](https://github.com/CloudCompare/CloudCompare)
- [CloudCompare Documentation](https://www.cloudcompare.org/doc/wiki/index.php/Main_Page)

## License

CloudCompare is available under the GPL2 license. Refer to CloudCompare's license for details.

## Support

For issues with CloudCompare, visit the official repository. For Docker-specific issues, check the container logs and verify all mounts and environment variables are correctly set.

## Author

TAMANJI COURAGE --- Stratafy.co.za