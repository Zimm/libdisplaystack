ifeq ($(FW_RULES_LOADED),)
include $(FW_MAKEDIR)/rules.mk
endif

.PHONY: internal-framework-all_ internal-framework-stage_ internal-framework-compile

ifeq ($($(FW_INSTANCE)_FRAMEWORK_NAME),)
LOCAL_FRAMEWORK_NAME = $(FW_INSTANCE)
else
LOCAL_FRAMEWORK_NAME = $($(FW_INSTANCE)_FRAMEWORK_NAME)
endif

AUXILIARY_LDFLAGS += -dynamiclib -install_name $($(FW_INSTANCE)_INSTALL_PATH)/$(LOCAL_FRAMEWORK_NAME).framework/$(FW_INSTANCE)

ifeq ($(FW_MAKE_PARALLEL_BUILDING), no)
internal-framework-all_:: $(FW_OBJ_DIR) $(FW_OBJ_DIR)/$(FW_INSTANCE)
else
internal-framework-all_:: $(FW_OBJ_DIR)
	$(ECHO_NOTHING)$(MAKE) --no-print-directory --no-keep-going \
		internal-framework-compile \
		FW_TYPE=$(FW_TYPE) FW_INSTANCE=$(FW_INSTANCE) FW_OPERATION=compile \
		FW_BUILD_DIR="$(FW_BUILD_DIR)" _FW_MAKE_PARALLEL=yes$(ECHO_END)

internal-framework-compile: $(FW_OBJ_DIR)/$(FW_INSTANCE)
endif

$(FW_OBJ_DIR)/$(FW_INSTANCE): $(OBJ_FILES_TO_LINK)
ifeq ($(OBJ_FILES_TO_LINK),)
	$(WARNING_EMPTY_LINKING)
endif
	$(ECHO_LINKING)$(TARGET_CXX) $(ALL_LDFLAGS) -o $@ $^$(ECHO_END)
ifeq ($(DEBUG),)
	$(ECHO_STRIPPING)$(TARGET_STRIP) -x $@$(ECHO_END)
endif   
	$(ECHO_SIGNING)$(FW_CODESIGN_COMMANDLINE) $@$(ECHO_END)

FW_SHARED_BUNDLE_RESOURCE_PATH = $(FW_STAGING_DIR)$($(FW_INSTANCE)_INSTALL_PATH)/$(LOCAL_FRAMEWORK_NAME).framework
include $(FW_MAKEDIR)/instance/shared/bundle.mk

internal-framework-stage_:: shared-instance-bundle-stage
	$(ECHO_NOTHING)mkdir -p "$(FW_SHARED_BUNDLE_RESOURCE_PATH)"$(ECHO_END)
	$(ECHO_NOTHING)cp $(FW_OBJ_DIR)/$(FW_INSTANCE) "$(FW_SHARED_BUNDLE_RESOURCE_PATH)"$(ECHO_END)
