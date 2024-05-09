#!/bin/bash

# Enable strict mode for bash scripting
set -euo pipefail

# Define colors for echo outputs
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# ASCII Art
echo -e "${GREEN}
 ██████   ██████    ███████    ██████   █████ ██████████ ███████████      ███████      
░░██████ ██████   ███░░░░░███ ░░██████ ░░███ ░░███░░░░░█░░███░░░░░███   ███░░░░░███    
 ░███░█████░███  ███     ░░███ ░███░███ ░███  ░███  █ ░  ░███    ░███  ███     ░░███   
 ░███░░███ ░███ ░███      ░███ ░███░░███░███  ░██████    ░██████████  ░███      ░███   
 ░███ ░░░  ░███ ░███      ░███ ░███ ░░██████  ░███░░█    ░███░░░░░███ ░███      ░███   
 ░███      ░███ ░░███     ███  ░███  ░░█████  ░███ ░   █ ░███    ░███ ░░███     ███    
 █████     █████ ░░░███████░   █████  ░░█████ ██████████ █████   █████ ░░░███████░     
░░░░░     ░░░░░    ░░░░░░░    ░░░░░    ░░░░░ ░░░░░░░░░░ ░░░░░   ░░░░░    ░░░░░░░       
                                                                                       
                                                                                       
                                                                                       
 ██████   ██████ █████ ██████   █████ ██████████ ███████████                           
░░██████ ██████ ░░███ ░░██████ ░░███ ░░███░░░░░█░░███░░░░░███                          
 ░███░█████░███  ░███  ░███░███ ░███  ░███  █ ░  ░███    ░███                          
 ░███░░███ ░███  ░███  ░███░░███░███  ░██████    ░██████████                           
 ░███ ░░░  ░███  ░███  ░███ ░░██████  ░███░░█    ░███░░░░░███                          
 ░███      ░███  ░███  ░███  ░░█████  ░███ ░   █ ░███    ░███                          
 █████     █████ █████ █████  ░░█████ ██████████ █████   █████                         
░░░░░     ░░░░░ ░░░░░ ░░░░░    ░░░░░ ░░░░░░░░░░ ░░░░░   ░░░░░                          
                                                                  By SleepTheGod
${NC}"

# Function to check if running as root
function check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}This script must be run as root${NC}" 1>&2
        exit 1
    fi
}

# Function to install required packages
function install_dependencies() {
    echo "Updating package lists..."
    sudo apt-get update
    echo "Installing required packages..."
    sudo apt-get install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev
}

# Function to clone or update XMRig
function setup_xmrig() {
    echo "Checking for existing XMRig directory..."
    if [ ! -d "xmrig" ]; then
        echo "Cloning XMRig from GitHub..."
        git clone https://github.com/xmrig/xmrig.git
    else
        echo "XMRig directory already exists, pulling latest updates..."
        cd xmrig
        git pull
        cd ..
    fi

    cd xmrig
    echo "Setting up build directory..."
    if [ ! -d "build" ]; then
        mkdir build
    fi
    cd build
    echo "Configuring XMRig with cmake..."
    cmake .. || { echo -e "${RED}Error: Failed to configure XMRig. Please check dependencies and try again.${NC}"; exit 1; }
    echo "Building XMRig..."
    make || { echo -e "${RED}Error: Failed to build XMRig. Please check dependencies and try again.${NC}"; exit 1; }
}

# Function to configure the mining pool
function configure_mining_pool() {
    echo "Configuring mining pool..."
    cat > ../config.json << EOF
{
    "autosave": true,
    "cpu": true,
    "opencl": false,
    "cuda": false,
    "pools": [
        {
            "algo": "randomx",
            "url": "http://xmr1.rs.me:18089",
            "user": "YourMoneroAddress",
            "pass": "x",
            "tls": false,
            "keepalive": true,
            "coin": "monero"
        }
    ]
}
EOF
    echo -e "${GREEN}Mining pool configured successfully.${NC}"
}

# Function to start the miner
function start_mining() {
    echo "Starting mining process..."
    ./xmrig
}

# Main script logic
check_root
install_dependencies
setup_xmrig
configure_mining_pool
start_mining
