#!/bin/bash
set -e

echo "Initializing Proton..."
"$PROTON_DIR/proton" run true || true

echo "Starting FMD2..."
exec "$PROTON_DIR/proton" run /app/FMD2/FMD2.exe
