{ pkgs }:

pkgs.writeShellScriptBin "run-container" ''
  set -e

  NAME=""
  IMAGE=""
  PORT=""
  VOLUME=""
  ENV_VARS=""
  DATA_DIR=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --name)
        NAME="$2"
        shift 2
        ;;
      --image)
        IMAGE="$2"
        shift 2
        ;;
      --port)
        PORT="$2"
        shift 2
        ;;
      --volume)
        VOLUME="$2"
        shift 2
        ;;
      --env)
        ENV_VARS="$ENV_VARS $1=$2"
        shift 2
        ;;
      --data-dir)
        DATA_DIR="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  if [ -z "$NAME" ] || [ -z "$IMAGE" ]; then
    echo "Usage: run-container --name NAME --image IMAGE [--port PORT] [--volume VOLUME] [--env KEY=VALUE]"
    exit 1
  fi

  # Detect container runtime
  RUNTIME=""
  IS_MACOS=false

  # Detect macOS
  if command -v uname &> /dev/null && [ "$(uname -s)" = "Darwin" ]; then
    IS_MACOS=true
  fi

  # Try nix-containers first (preferred on NixOS/Nix-based systems)
  if command -v nix-container-run &> /dev/null; then
    RUNTIME="nix-containers"
    echo "Using nix-containers runtime..."
  elif command -v podman &> /dev/null; then
    RUNTIME="podman"
    echo "Using Podman runtime..."
  elif command -v docker &> /dev/null; then
    RUNTIME="docker"
    echo "Using Docker runtime..."
  elif command -v orbstack &> /dev/null; then
    # OrbStack on macOS
    RUNTIME="docker"
    echo "Using OrbStack (Docker-compatible) runtime..."
  else
    echo "Error: No container runtime found (nix-containers, podman, docker, or orbstack)"
    echo ""
    if [ "$IS_MACOS" = "true" ]; then
      echo "On macOS, please install one of:"
      echo "  - OrbStack (recommended): https://orbstack.dev"
      echo "  - Docker Desktop: https://docker.com"
      echo "  - Podman: brew install podman"
    else
      echo "Please install one of:"
      echo "  - nix-containers: nix profile install nixpkgs#nix-containers"
      echo "  - podman: nix profile install nixpkgs#podman"
      echo "  - docker: nix profile install nixpkgs#docker"
    fi
    exit 1
  fi

  # Check if container is already running
  if $RUNTIME ps --format '{{.Names}}' 2>/dev/null | grep -q "^clearsky-$NAME$"; then
    echo "Container 'clearsky-$NAME' is already running"
    exit 0
  fi

  # Handle macOS volume paths
  if [ "$IS_MACOS" = "true" ] && [ -n "$VOLUME" ]; then
    # On macOS with Docker Desktop/OrbStack, volumes need special handling
    # Convert ~/ to /Users/username/
    VOLUME=$(echo "$VOLUME" | sed "s|^$HOME/|/Users/$USER/|g")
    echo "Note: Adjusted volume path for macOS: $VOLUME"
  fi

  # Build run command based on runtime
  case "$RUNTIME" in
    nix-containers)
      CMD="nix-container-run --name clearsky-$NAME --image $IMAGE"
      if [ -n "$PORT" ]; then
        CMD="$CMD --port $PORT:$PORT"
      fi
      if [ -n "$VOLUME" ]; then
        CMD="$CMD --volume $VOLUME"
      fi
      if [ -n "$ENV_VARS" ]; then
        for env_pair in $ENV_VARS; do
          CMD="$CMD --env $env_pair"
        done
      fi
      ;;
    podman|docker)
      CMD="$RUNTIME run -d --rm --name clearsky-$NAME"
      if [ -n "$PORT" ]; then
        CMD="$CMD -p $PORT:$PORT"
      fi
      if [ -n "$VOLUME" ]; then
        CMD="$CMD -v $VOLUME"
      fi
      if [ -n "$ENV_VARS" ]; then
        for env_pair in $ENV_VARS; do
          CMD="$CMD -e $env_pair"
        done
      fi
      CMD="$CMD $IMAGE"
      ;;
  esac

  echo "Starting container: $CMD"
  eval $CMD

  echo "Container 'clearsky-$NAME' started successfully"
  
  # macOS-specific post-start message
  if [ "$IS_MACOS" = "true" ]; then
    echo ""
    echo "Note: On macOS, containers run in a lightweight VM."
    echo "First start may take a minute while the VM initializes."
    echo ""
  fi
''
