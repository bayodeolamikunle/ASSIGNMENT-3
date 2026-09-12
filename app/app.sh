#!/bin/bash

show_help() {
    echo "Usage:"
    echo "  ./app/app.sh system-info"
    echo "  ./app/app.sh check-host <host>"
    echo "  ./app/app.sh check-port <host> <port>"
    echo "  ./app/app.sh help"
}

system_info() {
    echo "System Information"
    echo "------------------"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Date: $(date)"
    echo "OS: $(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
}

check_host() {
    local host="$1"

    if [[ -z "$host" ]]; then
        echo "Error: host is required."
        return 2
    fi

    echo "Checking host: $host"

    if getent hosts "$host" > /dev/null; then
        echo "Host resolved successfully."
        getent hosts "$host"
        return 0
    else
        echo "Host could not be resolved."
        return 1
    fi
}

check_port() {
    local host="$1"
    local port="$2"

    if [[ -z "$host" || -z "$port" ]]; then
        echo "Error: host and port are required."
        return 2
    fi

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: port must be numeric."
        return 2
    fi

    if (( port < 1 || port > 65535 )); then
        echo "Error: port must be between 1 and 65535."
        return 2
    fi

    echo "Checking TCP connectivity to $host:$port"

    if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        echo "TCP port $port is open on $host."
        return 0
    else
        echo "TCP port $port is not reachable on $host."
        return 1
    fi
}

case "$1" in
    system-info)
        if [[ $# -ne 1 ]]; then
            echo "Error: system-info does not accept additional arguments."
            exit 2
        fi
        system_info
        ;;

    check-host)
        if [[ $# -ne 2 ]]; then
            echo "Error: check-host requires a host."
            exit 2
        fi
        check_host "$2"
        ;;

    check-port)
        if [[ $# -ne 3 ]]; then
            echo "Error: check-port requires a host and port."
            exit 2
        fi
        check_port "$2" "$3"
        ;;

    help|"")
        if [[ $# -gt 1 ]]; then
            echo "Error: invalid arguments."
            exit 2
        fi
        show_help
        ;;

    *)
        echo "Error: invalid command: $1"
        show_help
        exit 2
        ;;
esac
