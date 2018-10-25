
GOOGLETEST_IVPM_MKFILES_DIR:=$(dir $(lastword $(MAKEFILE_LIST)))
GOOGLETEST_IVPM_DIR:=$(abspath $(GOOGLETEST_IVPM_MKFILES_DIR)/..)

ifneq (1,$(RULES))

SRC_DIRS += $(GOOGLETEST_IVPM_DIR)/googletest/include
SRC_DIRS += $(GOOGLETEST_IVPM_DIR)/googletest/src

else # Rules

libgoogletest.o : gtest-all.o
	$(Q)$(LD) -r -o $@ gtest-all.o

endif

