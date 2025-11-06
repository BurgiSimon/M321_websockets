#!/bin/bash

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting development environment...${NC}"

# Store PIDs
BACKEND_PID=""
FRONTEND_PID=""

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Shutting down...${NC}"
    if [ ! -z "$BACKEND_PID" ]; then
        echo -e "${BLUE}[Backend]${NC} Stopping (PID: $BACKEND_PID)"
        kill $BACKEND_PID 2>/dev/null
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        echo -e "${GREEN}[Frontend]${NC} Stopping (PID: $FRONTEND_PID)"
        kill $FRONTEND_PID 2>/dev/null
    fi
    exit 0
}

# Trap Ctrl+C
trap cleanup SIGINT SIGTERM

# Start backend
echo -e "${BLUE}[Backend]${NC} Starting WebSocket server..."
(cd backend && bun --hot index.ts 2>&1 | sed "s/^/$(echo -e ${BLUE}[Backend]${NC}) /") &
BACKEND_PID=$!

# Start frontend
echo -e "${GREEN}[Frontend]${NC} Starting Vite dev server..."
(cd frontend && bun run dev 2>&1 | sed "s/^/$(echo -e ${GREEN}[Frontend]${NC}) /") &
FRONTEND_PID=$!

echo -e "${YELLOW}Both servers started!${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop both servers${NC}"

# Wait for both processes
wait
