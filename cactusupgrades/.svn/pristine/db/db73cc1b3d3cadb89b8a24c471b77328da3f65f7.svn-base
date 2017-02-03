function pathadd() {
  # TODO add check for empty path
  # and what happens if $1 == $2
  # Copy into temp variables
  PATH_NAME=$1
  PATH_VAL=${!1}
  if [[ ":$PATH_VAL:" != *":$2:"* ]]; then
    PATH_VAL="$2${PATH_VAL:+":$PATH_VAL"}"
    echo "- $1 += $2"

    # use eval to reset the target
    eval "$PATH_NAME=$PATH_VAL"
  fi

}

CACTUS_ROOT=/opt/cactus
CALOL2_TESTS=$( readlink -f $(dirname $BASH_SOURCE)/ )
CALOL2_ROOT=$( readlink -f ${CALOL2_TESTS}/.. )
CALOL2_ETC=$( readlink -f ${CALOL2_ROOT}/calol2/etc)


pathadd LD_LIBRARY_PATH "${CACTUS_ROOT}/lib"

# add to path
#PATH="${CALOL2_ROOT}/tests/scripts:${PATH}"
pathadd PATH "${CALOL2_ROOT}/tests/bin"
pathadd PATH "${CALOL2_ROOT}/tests/scripts"
pathadd LD_LIBRARY_PATH "${CALOL2_ROOT}/tests/lib"

# add python path
pathadd PYTHONPATH "${CALOL2_ROOT}/python/pkg"
pathadd PYTHONPATH "${CALOL2_ROOT}/tests/python"

# add libary path
#pathadd LD_LIBRARY_PATH "${CALOL2_ROOT}/calol2/lib/${XDAQ_OS}/${XDAQ_PLATFORM}"
pathadd LD_LIBRARY_PATH "${CALOL2_ROOT}/calol2/lib"

export CACTUS_ROOT CALOL2_TESTS CALOL2_ROOT CALOL2_ETC LD_LIBRARY_PATH PYTHONPATH
