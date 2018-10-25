#****************************************************************************
#* ivpm.mk
#*
#****************************************************************************
BUILD_NAME = WB_SYS_IP
SCRIPTS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
ROOT_DIR := $(abspath $(SCRIPTS_DIR)/..)
BUILD_DEPS = $(ROOT_DIR)/build/googletest-ivpm.d
PROJECT := $(notdir $(ROOT_DIR))
PACKAGES_DIR ?= $(ROOT_DIR)/packages
LIB_DIR = $(ROOT_DIR)/lib

GOOGLETEST_VERSION=1.8.1
GOOGLETEST_URL=https://github.com/google/googletest/archive/release-$(GOOGLETEST_VERSION).tar.gz
GOOGLETEST_DIR=googletest-release-$(GOOGLETEST_VERSION)
GOOGLETEST_TGZ=$(ROOT_DIR)/build/$(GOOGLETEST_DIR).tar.gz

ifneq (true,$(VERBOSE))
Q=@
endif

# Must support dual modes: 
# - build dependencies if this project is the active one
# - rely on the upper-level makefile to resolve dependencies if we're not
-include $(PACKAGES_DIR)/packages.mk
include $(ROOT_DIR)/etc/ivpm.info

include $(MK_INCLUDES)

SRC_DIRS += $(PROJECT)

SRC := $(foreach dir,$(SRC_DIRS),$(wildcard $(ROOT_DIR)/src/$(dir)/*.scala))

RULES := 1

ifeq (true,$(PHASE2))
build : $(BUILD_DEPS)
else
build : $($(PROJECT)_deps)
	$(Q)$(MAKE) -f $(SCRIPTS_DIR)/ivpm.mk PHASE2=true VERBOSE=$(VERBOSE) build
endif

release : build
	$(Q)rm -rf $(ROOT_DIR)/build
	$(Q)mkdir -p $(ROOT_DIR)/build/$(PROJECT)
	$(Q)cp -r \
          $(ROOT_DIR)/lib \
          $(ROOT_DIR)/etc \
          $(ROOT_DIR)/build/$(PROJECT)
	$(Q)cd $(ROOT_DIR)/build ; \
		tar czf $(PROJECT)-$(version).tar.gz $(PROJECT)
	$(Q)rm -rf $(ROOT_DIR)/build/$(PROJECT)

$(ROOT_DIR)/build/googletest-ivpm.d : $(GOOGLETEST_TGZ)
	$(Q)if test ! -d `dirname $@`; then mkdir -p `dirname $@`; fi
	$(Q)rm -rf $(ROOT_DIR)/build/$(GOOGLETEST_DIR)
	$(Q)rm -rf $(ROOT_DIR)/googletest
	$(Q)rm -rf $(ROOT_DIR)/googlemock
	$(Q)cd $(ROOT_DIR)/build ; tar xzf $(GOOGLETEST_TGZ)
	$(Q)mv $(ROOT_DIR)/build/$(GOOGLETEST_DIR)/googletest $(ROOT_DIR)
	$(Q)mv $(ROOT_DIR)/build/$(GOOGLETEST_DIR)/googlemock $(ROOT_DIR)
	$(Q)rm -rf $(ROOT_DIR)/build/$(GOOGLETEST_DIR)
	$(Q)touch $@

$(GOOGLETEST_TGZ) : 
	$(Q)if test ! -d `dirname $@`; then mkdir -p `dirname $@`; fi
	$(Q)wget --no-check-certificate -O $@ $(GOOGLETEST_URL)

include $(MK_INCLUDES)

-include $(PACKAGES_DIR)/packages.mk

