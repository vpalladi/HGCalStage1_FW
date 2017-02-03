CALOL2_ROOT = $(shell pwd)/..

BUILD_HOME:=$(shell cd $(CALOL2_ROOT);pwd)

include  $(CALOL2_ROOT)/config/mfCommonDefs.mk

Project = calol2
Package = tests

PackagePath = $(CALOL2_ROOT)/tests
PackageName = cactusupgradeprojects-calol2-tests

Packager = Alessandro Thea, Tom Williams

PACKAGE_VER_MAJOR = 0
PACKAGE_VER_MINOR = 1
PACKAGE_VER_PATCH = 4
PACKAGE_RELEASE = 0

PackageRequires = cactuscore-uhal-uhal >= 2.4.0, cactuscore-uhal-uhal < 2.5.0
PackageBuildRequires = ${PackageRequires}

Library = # cactus_calol2_tests

Includes = include \
    $(CALOL2_ROOT)/calol2/include \
    $(CACTUS_ROOT)/include 

Libraries = \
    boost_system \
    boost_program_options \
    boost_date_time \
    boost_thread \
    boost_regex \
    boost_filesystem \
    cactus_extern_pugixml \
    cactus_uhal_log \
    cactus_uhal_uhal \
    cactus_uhal_grammars \
    cactus_calol2_calol2 

LibraryPaths = \
    lib/ \
    $(CALOL2_ROOT)/calol2/lib \
    $(CACTUS_ROOT)/lib


ExecutableLibraries = ${Libraries} \
    cactus_uhal_uhal 

Includes = include \
    $(CALOL2_ROOT)/calol2/include \
    $(CACTUS_ROOT)/include

LibraryPaths = \
    lib/ \
    $(CALOL2_ROOT)/calol2/lib \
    $(CACTUS_ROOT)/lib

include ${CALOL2_ROOT}/config/mfRules.mk
include ${CALOL2_ROOT}/config/mfRPMRules.mk
