# CloudCompare Docker Setup

This Docker image provides CloudCompare running in a headless environment with web access via noVNC. Perfect for point cloud processing, visualization, and batch operations.

## What's Included

- **CloudCompare**: Built from source with full dependencies
- **VNC Server**: Remote desktop access via X11VNC
- **noVNC**: Web-based VNC viewer accessible from any browser
- **Xvfb**: Virtual framebuffer for headless operation
- **Fluxbox**: Lightweight window manager
- **XTerm**: Terminal for CLI commands

## Prerequisites

- Docker installed and running
- At least 2GB of free disk space
- Port 6080 available for noVNC access

## Building the Image

```bash
cd CloudCompare
docker build -t cloudcompare:latest .
```

Build with custom tag:
```bash
docker build -t myregistry/cloudcompare:1.0 .
```

## Running the Container

### Basic Usage (Interactive Mode)

```bash
docker run -it \
  -p 6080:6080 \
  --name cloudcompare \
  cloudcompare:latest
```

Then access CloudCompare at: **http://localhost:6080**

### With Data Directory Mount

Mount a local directory containing point cloud files:

```bash
docker run -it \
  -p 6080:6080 \
  -v /path/to/your/data:/data \
  --name cloudcompare \
  cloudcompare:latest
```

**Example:**
```bash
docker run -it \
  -p 6080:6080 \
  -v ~/my_point_clouds:/data \
  --name cloudcompare \
  cloudcompare:latest
```

Files in `/data` will be accessible from CloudCompare GUI and command line.

### Auto-Launch CloudCompare GUI

```bash
docker run -it \
  -p 6080:6080 \
  -v /path/to/your/data:/data \
  -e RUN_CLOUDCOMPARE=1 \
  --name cloudcompare \
  cloudcompare:latest
```

### Headless/Batch Mode

For automated point cloud processing without GUI:

```bash
docker run -it \
  -v /path/to/your/data:/data \
  -e HEADLESS_MODE=1 \
  -e CC_BATCH_SCRIPT=/data/process.ccscript \
  --name cloudcompare-batch \
  cloudcompare:latest /usr/local/bin/start_vnc.sh
```

## Advanced Usage

### Interactive Terminal Access

Start container and use xterm within the X11 session:

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
