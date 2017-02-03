#!/bin/bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C. Goobye!"
        exit 0
}

function usage() {
    echo 'AAAA'
}

#function to display commands
exe() { echo "> $@" ; "$@" || exit 1; }


REFERENCE_INPUT_FILE="${CALOL2_ROOT}/tests/etc/calol2/reference/ttbar/rx_summary.txt"
CONNECTIONS="file://${CALOL2_ROOT}/tests/etc/calol2/connections-Schroff2.xml"
BOARD=S2_B9
OUTPUT_DIR=valMP

MP7_BTLR="mp7butler.py -l -c ${CONNECTIONS}"

exe ${MP7_BTLR} scansd ${BOARD}

exe ${MP7_BTLR} reset ${BOARD}