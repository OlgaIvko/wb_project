#!/bin/bash

echo "🔄 Restarting Wildberries API Application..."
./docker/stop.sh
sleep 5
./docker/start.sh
