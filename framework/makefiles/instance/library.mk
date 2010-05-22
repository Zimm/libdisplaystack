ifeq ($(FW_RULES_LOADED),)
include $(FW_MAKEDIR)/rules.mk
endif

.PHONY: internal-library-all_ internal-library-stage_ internal-library-compile

LOCAL_INSTALL_PATH ?= $(strip $($(FW_INSTANCE)_INSTALL_PATH))
ifeq ($(LOCAL_INSTALL_PATH),)
	LOCAL_INSTALL_PATH = /usr/lib
endif

AUXILIARY_LDFLAGS += -dynamiclib -install_name $(LOCAL_INSTALL_PATH)/$(FW_INSTANCE).dylib

ifeq ($(FW_MAKE_PARALLEL_BUILDING), no)
internal-library-all_:: $(FW_OBJ_DIR) $(FW_OBJ_DIR)/$(FW_INSTANCE).dylib
else
internal-library-all_:: $(FW_OBJ_DIR)
	$(ECHO_NOTHING)$(MAKE) --no-print-directory --no-keep-going \
		internal-library-compile \
		FW_TYPE=$(FW_TYPE) FW_INSTANCE=$(FW_INSTANCE) FW_OPERATION=compile \
		FW_BUILD_DIR="$(FW_BUILD_DIR)" _FW_MAKE_PARALLEL=yes$(ECHO_END)

internal-library-compile: $(FW_OBJ_DIR)/$(FW_INSTANCE).dylib
endif

$(FW_OBJ_DIR)/$(FW_INSTANCE).dylib: $(OBJ_FILES_TO_LINK)
ifeq ($(OBJ_FILES_TO_LINK),)
	$(WARNING_EMPTY_LINKING)
endif
	$(ECHO_LINKING)$(TARGET_CXX) $(ALL_LDFLAGS) -o $@ $^$(ECHO_END)
ifeq ($(DEBUG),)
	$(ECHO_STRIPPING)$(TARGET_STRIP) -x $@$(ECHO_END)
endif   
	$(ECHO_SIGNING)$(FW_CODESIGN_COMMANDLINE) $@$(ECHO_END)


internal-library-stage_::
	$(ECHO_NOTHING)mkdir -p "$(FW_STAGING_DIR)$(LOCAL_INSTALL_PATH)/"$(ECHO_END)
	$(ECHO_NOTHING)cp $(FW_OBJ_DIR)/$(FW_INSTANCE).dylib "$(FW_STAGING_DIR)$(LOCAL_INSTALL_PATH)/"$(ECHO_END)
