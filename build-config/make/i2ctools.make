#-------------------------------------------------------------------------------
#
#
#-------------------------------------------------------------------------------
#
# This is a makefile fragment that defines the build of i2ctools
#

I2CTOOLS_VERSION	= 3.1.1
I2CTOOLS_TARBALL	= i2c-tools-$(I2CTOOLS_VERSION).tar.bz2
I2CTOOLS_TARBALL_URLS	+= $(ONIE_MIRROR) http://jdelvare.nerim.net/mirror/i2c-tools
I2CTOOLS_BUILD_DIR	= $(MBUILDDIR)/i2c-tools
I2CTOOLS_DIR		= $(I2CTOOLS_BUILD_DIR)/i2c-tools-$(I2CTOOLS_VERSION)

I2CTOOLS_SRCPATCHDIR	= $(PATCHDIR)/i2ctools
I2CTOOLS_PATCHDIR	= $(I2CTOOLS_BUILD_DIR)/patch
I2CTOOLS_DOWNLOAD_STAMP = $(DOWNLOADDIR)/i2ctools-download
I2CTOOLS_SOURCE_STAMP	= $(STAMPDIR)/i2ctools-source
I2CTOOLS_PATCH_STAMP	= $(STAMPDIR)/i2ctools-patch
I2CTOOLS_BUILD_STAMP	= $(STAMPDIR)/i2ctools-build
I2CTOOLS_INSTALL_STAMP	= $(STAMPDIR)/i2ctools-install
I2CTOOLS_STAMP		= $(I2CTOOLS_SOURCE_STAMP) \
			  $(I2CTOOLS_PATCH_STAMP) \
			  $(I2CTOOLS_BUILD_STAMP) \
			  $(I2CTOOLS_INSTALL_STAMP)

I2CTOOLS_PROGRAMS = i2cget i2cset i2cdump i2cdetect

PHONY += i2ctools i2ctools-download i2ctools-source i2ctools-patch \
	 i2ctools-build i2ctools-install i2ctools-clean \
	 i2ctools-download-clean

I2CTOOLS_MACHINEPATCHDIR = $(shell \
			   test -d $(MACHINEDIR)/i2ctools && \
			   echo "$(MACHINEDIR)/i2ctools")

ifneq ($(I2CTOOLS_MACHINEPATCHDIR),)
  I2CTOOLS_MACHINEPATCHDIR_FILES = $(I2CTOOLS_MACHINEPATCHDIR)/*
endif

i2ctools: $(I2CTOOLS_STAMP)

DOWNLOAD += $(I2CTOOLS_DOWNLOAD_STAMP)
i2ctools-download: $(I2CTOOLS_DOWNLOAD_STAMP)
$(I2CTOOLS_DOWNLOAD_STAMP): $(PROJECT_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Getting upstream i2ctools ===="
	$(Q) $(SCRIPTDIR)/fetch-package $(DOWNLOADDIR) $(UPSTREAMDIR) \
		$(I2CTOOLS_TARBALL) $(I2CTOOLS_TARBALL_URLS)
	$(Q) touch $@

SOURCE += $(I2CTOOLS_SOURCE_STAMP)
i2ctools-source: $(I2CTOOLS_SOURCE_STAMP)
$(I2CTOOLS_SOURCE_STAMP): $(TREE_STAMP) | $(I2CTOOLS_DOWNLOAD_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Extracting upstream i2ctools ===="
	$(Q) $(SCRIPTDIR)/extract-package $(I2CTOOLS_BUILD_DIR) $(DOWNLOADDIR)/$(I2CTOOLS_TARBALL)
	$(Q) touch $@

i2ctools-patch: $(I2CTOOLS_PATCH_STAMP)
$(I2CTOOLS_PATCH_STAMP): $(I2CTOOLS_SRCPATCHDIR)/* $(I2CTOOLS_MACHINEPATCHDIR_FILES) $(I2CTOOLS_SOURCE_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Patching i2ctools ===="
	$(Q) mkdir -p $(I2CTOOLS_DIR)/sys_eeprom
	$(Q) cp $(I2CTOOLS_DIR)/eepromer/24cXX.c $(I2CTOOLS_DIR)/sys_eeprom/24cXX.c
	$(Q) cp $(I2CTOOLS_DIR)/eepromer/24cXX.h $(I2CTOOLS_DIR)/sys_eeprom/24cXX.h
	$(Q) mkdir -p $(I2CTOOLS_PATCHDIR)
	$(Q) cp $(I2CTOOLS_SRCPATCHDIR)/* $(I2CTOOLS_PATCHDIR)
ifneq ($(I2CTOOLS_MACHINEPATCHDIR),)
	$(Q) if [ -r $(I2CTOOLS_MACHINEPATCHDIR)/series ] ; then \
		cat $(I2CTOOLS_MACHINEPATCHDIR)/series >> $(I2CTOOLS_PATCHDIR)/series ; \
		cp $(I2CTOOLS_MACHINEPATCHDIR)/*.patch $(I2CTOOLS_PATCHDIR) ; \
		else \
		echo "Unable to find machine dependent i2ctools patch series: $(I2CTOOLS_MACHINEPATCHDIR)/series" ; \
		exit 1 ; \
		fi
endif
	$(Q) $(SCRIPTDIR)/apply-patch-series $(I2CTOOLS_PATCHDIR)/series $(I2CTOOLS_DIR)
	$(Q) touch $@

ifndef MAKE_CLEAN
I2CTOOLS_NEW_FILES = $(shell test -d $(I2CTOOLS_DIR) && test -f $(I2CTOOLS_BUILD_STAMP) && \
	              find -L $(I2CTOOLS_DIR) -newer $(I2CTOOLS_BUILD_STAMP) -type f -print -quit)
endif

i2ctools-build: $(I2CTOOLS_BUILD_STAMP)
$(I2CTOOLS_BUILD_STAMP): $(I2CTOOLS_NEW_FILES) $(I2CTOOLS_PATCH_STAMP) \
	$(ZLIB_INSTALL_STAMP) | $(DEV_SYSROOT_INIT_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "====  Building i2ctools-$(I2CTOOLS_VERSION) ===="
	$(Q) PATH='$(CROSSBIN):$(PATH)'	$(MAKE) -C $(I2CTOOLS_DIR) \
		CROSS_COMPILE=$(CROSSPREFIX) CFLAGS="$(ONIE_CFLAGS)" \
		LDFLAGS="$(ONIE_LDFLAGS)" SYSEEPROM_ENABLE=$(I2CTOOLS_SYSEEPROM)
	$(Q) touch $@

i2ctools-install: $(I2CTOOLS_INSTALL_STAMP)
$(I2CTOOLS_INSTALL_STAMP): $(SYSROOT_INIT_STAMP) $(I2CTOOLS_BUILD_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Installing i2ctools in $(DEV_SYSROOT) ===="
	$(Q) PATH='$(CROSSBIN):$(PATH)'	$(MAKE) -C $(I2CTOOLS_DIR) \
		CROSS_COMPILE=$(CROSSPREFIX) CFLAGS="$(ONIE_CFLAGS)" \
		LDFLAGS="$(ONIE_LDFLAGS)" SYSEEPROM_ENABLE=$(I2CTOOLS_SYSEEPROM)
	$(Q) for file in $(I2CTOOLS_PROGRAMS); do \
		cp -av $(I2CTOOLS_DIR)/tools/$$file $(SYSROOTDIR)/usr/bin ; \
	     done
ifeq ($(I2CTOOLS_SYSEEPROM),yes)
	$(Q) cp -av $(I2CTOOLS_DIR)/sys_eeprom/onie-syseeprom $(SYSROOTDIR)/usr/bin/onie-syseeprom
endif
	$(Q) touch $@

USERSPACE_CLEAN += i2ctools-clean
i2ctools-clean:
	$(Q) rm -rf $(I2CTOOLS_BUILD_DIR)
	$(Q) rm -f $(I2CTOOLS_STAMP)
	$(Q) echo "=== Finished making $@ for $(PLATFORM)"

DOWNLOAD_CLEAN += i2ctools-download-clean
i2ctools-download-clean:
	$(Q) rm -f $(I2CTOOLS_DOWNLOAD_STAMP) $(DOWNLOADDIR)/$(I2CTOOLS_TARBALL)

#-------------------------------------------------------------------------------
#
# Local Variables:
# mode: makefile-gmake
# End:
