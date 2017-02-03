#!/bin/bash

#function to display commands
run() { echo "> $@" ; "$@" || exit 1; }

echo $# arguments

if [ "$#" -ne 1 ]; then
    echo "ERROR! Incorrect number of arguments (there should be only one, the output dir)"
    exit 1
fi

OUTPUT_DIR=$1

CONN_FILE=file://${CALOL2_ROOT}/tests/etc/calol2/connections-Schroff2.xml
BOARD=S2_B9_TUN
FWIMAGE=mp_33_core202_160616.bin
REFERENCE_INPUT_FILE=${CALOL2_ROOT}/tests/etc/calol2/reference/ttbar/rx_summary.txt

# mps_25_core202_160516.bin
# mp7butler.py -c ${CONN_FILE} rebootfpga ${BOARD} mps_160509_21_core201_tight.bin || exit 1
run calol2butler.py -c ${CONN_FILE} rebootfpga ${BOARD} ${FWIMAGE}
run calol2butler.py -c ${CONN_FILE} reset ${BOARD} --clksrc=internal
run calol2butler.py -c ${CONN_FILE} funkyread ${BOARD} -m cpp -o ${OUTPUT_DIR}/0_lutsAfterReboot_cpp.txt
run calol2butler.py -c ${CONN_FILE} funkyread ${BOARD} -m py -o ${OUTPUT_DIR}/0b_lutsAfterReboot_py.txt
run calol2butler.py -c ${CONN_FILE} xbuffers ${BOARD} rx PlayOnce --inject file://${REFERENCE_INPUT_FILE} -e=0-71
run calol2butler.py -c ${CONN_FILE} formatters ${BOARD} --tdrfmt strip,insert
run calol2butler.py -c ${CONN_FILE} xbuffers ${BOARD} tx Capture -e=60-65
run calol2butler.py -c ${CONN_FILE} capture ${BOARD} --out $OUTPUT_DIR/1_afterReboot --tx=60-65

run calol2butler.py -c ${CONN_FILE} reset ${BOARD} --clksrc=internal
run calol2butler.py -c ${CONN_FILE} funkyzeros ${BOARD}
run calol2butler.py -c ${CONN_FILE} funkyread ${BOARD} -m cpp -o ${OUTPUT_DIR}/2_lutsAfterLoadZeroes_cpp.txt
run calol2butler.py -c ${CONN_FILE} funkyread ${BOARD} -m py -o ${OUTPUT_DIR}/2b_lutsAfterLoadZeroes_py.txt
run calol2butler.py -c ${CONN_FILE} xbuffers ${BOARD} rx PlayOnce --inject file://${REFERENCE_INPUT_FILE} -e=0-71
run calol2butler.py -c ${CONN_FILE} formatters ${BOARD} --tdrfmt strip,insert
run calol2butler.py -c ${CONN_FILE} xbuffers ${BOARD} tx Capture -e=60-65
run calol2butler.py -c ${CONN_FILE} capture ${BOARD} --out $OUTPUT_DIR/3_afterLoadZeroes --tx=60-65

run calol2butler.py -c ${CONN_FILE} reset ${BOARD} --clksrc=internal
run calol2butler.py -c ${CONN_FILE} funkyrecovery ${BOARD} -p ../HexROMs/
run calol2butler.py -c ${CONN_FILE} funkyread ${BOARD} -m cpp -o ${OUTPUT_DIR}/4_lutsAfterLoadMifs_cpp.txt
run calol2butler.py -c ${CONN_FILE} funkyread ${BOARD} -m py -o ${OUTPUT_DIR}/4b_lutsAfterLoadMifs_py.txt
run calol2butler.py -c ${CONN_FILE} xbuffers ${BOARD} rx PlayOnce --inject file://${REFERENCE_INPUT_FILE} -e=0-71
run calol2butler.py -c ${CONN_FILE} formatters ${BOARD} --tdrfmt strip,insert
run calol2butler.py -c ${CONN_FILE} xbuffers ${BOARD} tx Capture -e=60-65
run calol2butler.py -c ${CONN_FILE} capture ${BOARD} --out $OUTPUT_DIR/5_afterLoadMifs --tx=60-65


