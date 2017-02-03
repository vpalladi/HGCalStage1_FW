CALOL2_ROOT = $(shell pwd)/..

BUILD_HOME:=$(shell cd $(CALOL2_ROOT);pwd)

include  $(CALOL2_ROOT)/config/mfCommonDefs.mk

# CxxFlags := $(filter-out -std=c++0x,$(CxxFlags))
CxxFlags += \
		-ftemplate-depth-128 \
		-O0 -rdynamic -finline-functions \
		-Wno-inline -DNDEBUG

Project = calol2
Package = python

PackagePath = $(CALOL2_ROOT)/python
PackageName = cactusupgradeprojects-calol2-python
PythonModules = ["calol2"]

$(info PythonModules=${PythonModules})

Packager = Alessandro Thea

PACKAGE_VER_MAJOR = 0
PACKAGE_VER_MINOR = 1
PACKAGE_VER_PATCH = 4
PACKAGE_RELEASE = 0

PackageRequires = cactuscore-uhal-uhal >= 2.4.0, cactuscore-uhal-uhal < 2.5.0
PackageBuildRequires=${PackageRequires}

Library = cactus_calo2_python
# The leading undescore is meant to be there
LibraryTarget = pkg/calol2/_pycalol2.so

Includes = \
    include \
    $(PYTHON_INCLUDE_PREFIX) \
    $(CALOL2_ROOT)/calol2/include \
    $(CACTUS_ROOT)/include 

Libraries = \
	boost_python \
	cactus_calol2_calol2

LibraryPaths = \
    $(CALOL2_ROOT)/calol2/lib \
    $(CACTUS_ROOT)/lib 


include ${CALOL2_ROOT}/config/mfRules.mk
include ${CALOL2_ROOT}/config/mfPythonRPMRules.mk
