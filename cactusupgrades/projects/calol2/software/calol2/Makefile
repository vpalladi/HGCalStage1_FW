PACKAGES = \
	calol2 \
	python \
	tests

VIRTUAL_PACKAGES = $(addsuffix /.virtual.Makefile,${PACKAGES})

FLAGS = $(ifeq $(MAKEFLAGS) "","",-$(MAKEFLAGS))

ifdef jobs
FLAGS+=-j ${jobs}
endif

# Makefile targets declared as phony
TARGETS = build rpm clean cleanrpm
.PHONY = $(TARGETS)

default: build

# Each target in TARGET will be built using the targets in VIRTUAL_PACKAGES
$(TARGETS): $(VIRTUAL_PACKAGES)

$(VIRTUAL_PACKAGES):
	$(MAKE) $(FLAGS) -C $(@D) $(MAKECMDGOALS)
