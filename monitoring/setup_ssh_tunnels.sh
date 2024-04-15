
#!/bin/bash

# Constants
JUMP_USER="at04480"
JUMP_HOST="192.168.122.1"
PI_USER="at04480"
BASE_DOMAIN="pi3lan.local"
START_PORT=49100

# Hosts to ignore
IGNORE_HOSTS=("pi3-r1-m1-l3-p2.pi3lan.local" "pi3-r1-m1-l1-p2.pi3lan.local")

# Function to setup SSH tunnel
setup_tunnel() {
    local hostname=$1
    local local_port=$2

    # Check if the hostname is in the ignore list
    if [[ " ${IGNORE_HOSTS[@]} " =~ " ${hostname} " ]]; then
        echo "Skipping setup for ${hostname} as it is on the ignore list."
        return
    fi
    # Attempt to establish an SSH tunnel
    ssh -f -N -L ${local_port}:localhost:9100 -J ${JUMP_USER}@${JUMP_HOST} ${PI_USER}@${hostname}
    if [ $? -eq 0 ]; then
        echo "Tunnel successfully set up for ${hostname} on local port ${local_port}"
    else
        echo "Failed to set up tunnel for ${hostname}; ignoring and continuing..."
    fi
}

# Main loop to iterate over your naming convention
port_counter=$START_PORT

for m in {1..2}; do
    for l in {1..5}; do
        for p in {1..4}; do
            hostname="pi3-r1-m${m}-l${l}-p${p}.${BASE_DOMAIN}"
            setup_tunnel $hostname $port_counter
            ((port_counter++))
        done
    done
done
