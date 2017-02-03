ifndef MP7_ROOT
  MP7_ROOT:=${MP7_BACK_TO_ROOT}
endif
BUILD_HOME=${MP7_ROOT}
$(info Using MP7_ROOT=${MP7_ROOT})
$(info Using BUILD_HOME=${BUILD_HOME})

# Cactus config. This section shall be sources from /opt/cactus/config
CACTUS_ROOT ?= /opt/cactus
CACTUS_PLATFORM=$(shell /usr/bin/python -c "import platform; print platform.platform()")
CACTUS_OS="unknown.os"

UNAME=$(strip $(shell uname -s))
ifeq ($(UNAME),Linux)
    ifneq ($(findstring redhat-5,$(CACTUS_PLATFORM)),)
        CACTUS_OS=slc5
    else ifneq ($(findstring redhat-6,$(CACTUS_PLATFORM)),)
        CACTUS_OS=slc6
    endif
endif
ifeq ($(UNAME),Darwin)
    CACTUS_OS=osx
endif

$(info OS Detected: $(CACTUS_OS))
# end of Cactus config

## Environment
# Make sure $CACTUS_ROOT/lib is present in LD_LIBRARY_PATH 
ifndef LD_LIBRARY_PATH
LD_LIBRARY_PATH:=$(CACTUS_ROOT)/lib
else
LD_LIBRARY_PATH:="$(CACTUS_ROOT)/lib:$(LD_LIBRARY_PATH)"
endif

export LD_LIBRARY_PATH


## Compilers
CPP:=g++
LD:=g++
	
## Tools
MakeDir=mkdir -p

## Python
PYTHON_VERSION ?= $(shell python -c "import distutils.sysconfig;print distutils.sysconfig.get_python_version()")
PYTHON_INCLUDE_PREFIX ?= $(shell python -c "import distutils.sysconfig;print distutils.sysconfig.get_python_inc()")

ifndef DEBUG
# Compiler flags
CxxFlags = -g -Wall -O0 -MMD -MP -fPIC -std=c++0x
LinkFlags = -g -shared -fPIC -Wall -Wl,-E 
ExecutableLinkFlags = -g -Wall -O3
else
CxxFlags = -g -ggdb -Wall -O0 -MMD -MP -fPIC  -std=c++0x
LinkFlags = -g -ggdb -shared -fPIC -Wl,-E -Wall
ExecutableLinkFlags = -g -ggdb -Wall
endif

