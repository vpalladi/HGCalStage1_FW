CALOL2_ROOT = $(shell pwd)/..

BUILD_HOME = $(CALOL2_ROOT)

include  $(CALOL2_ROOT)/config/mfCommonDefs.mk

Project = calol2
Package = calol2

PackagePath = $(CALOL2_ROOT)/calol2
PackageName = cactusupgradeprojects-calol2-calol2

Packager = Alessandro Thea, Tom Williams

PACKAGE_VER_MAJOR = 0
PACKAGE_VER_MINOR = 1
PACKAGE_VER_PATCH = 5
PACKAGE_RELEASE = 0

PackageRequires = cactuscore-uhal-uhal >= 2.4.0, cactuscore-uhal-uhal < 2.5.0
PackageBuildRequires = ${PackageRequires}

Library = cactus_calol2_calol2

Includes = \
    include \
    $(CACTUS_ROOT)/include

Libraries = \
    boost_date_time \
    boost_thread \
    boost_regex \
	boost_filesystem \
	cactus_extern_pugixml \
    cactus_uhal_log \
    cactus_uhal_grammars \
    cactus_uhal_uhal \
    cactus_mp7_mp7

	# boost_regex \
	# boost_system \
	# boost_program_options \

LibraryPaths = \
  $(CACTUS_ROOT)/lib

include ${CALOL2_ROOT}/config/mfRules.mk
include ${CALOL2_ROOT}/config/mfRPMRules.mk

