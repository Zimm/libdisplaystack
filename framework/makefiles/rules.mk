ifeq ($(FW_RULES_LOADED),)
FW_RULES_LOADED := 1

ifeq ($(FW_INSTANCE),)
	include $(FW_MAKEDIR)/master/rules.mk
else
	include $(FW_MAKEDIR)/instance/rules.mk
endif

ALL_CFLAGS = $(INTERNAL_CFLAGS) $(ADDITIONAL_CFLAGS) $(AUXILIARY_CFLAGS) $(TARGET_CFLAGS) $(DEBUG_CFLAGS) $(CFLAGS)
ALL_CCFLAGS = $(ADDITIONAL_CCFLAGS) $(CCFLAGS)
ALL_OBJCFLAGS = $(INTERNAL_OBJCFLAGS) $(ADDITIONAL_OBJCFLAGS) $(AUXILIARY_OBJCFLAGS) $(TARGET_OBJCFLAGS) $(DEBUG_CFLAGS) $(OBJCFLAGS)
ALL_OBJCCFLAGS = $(ADDITIONAL_OBJCCFLAGS) $(OBJCCFLAGS)

ALL_LDFLAGS = $(INTERNAL_LDFLAGS) $(ADDITIONAL_LDFLAGS) $(AUXILIARY_LDFLAGS) $(TARGET_LDFLAGS) $(LDFLAGS)

ifeq ($(FW_MAKE_PARALLEL_BUILDING), no)
.NOTPARALLEL:
else
ifneq ($(_FW_MAKE_PARALLEL), yes)
.NOTPARALLEL:
endif
endif

.SUFFIXES:

.SUFFIXES: .m .mm .c .cc

$(FW_OBJ_DIR)/%.m.o: %.m
	$(ECHO_COMPILING)$(TARGET_CXX) -x objective-c -c $(ALL_CFLAGS) $(ALL_OBJCFLAGS) $< -o $@$(ECHO_END)

$(FW_OBJ_DIR)/%.mm.o: %.mm
	$(ECHO_COMPILING)$(TARGET_CXX) -c $(ALL_CFLAGS) $(ALL_OBJCFLAGS) $(ALL_OBJCCFLAGS) $< -o $@$(ECHO_END)

$(FW_OBJ_DIR)/%.c.o: %.c
	$(ECHO_COMPILING)$(TARGET_CXX) -x c -c $(ALL_CFLAGS) $(ALL_CFLAGS) $< -o $@$(ECHO_END)

$(FW_OBJ_DIR)/%.cc.o: %.cc
	$(ECHO_COMPILING)$(TARGET_CXX) -c $(ALL_CFLAGS) $(ALL_CFLAGS) $(ALL_CCFLAGS) $< -o $@$(ECHO_END)

$(FW_OBJ_DIR)/%.xm.o: %.xm
	$(ECHO_LOGOS)$(FW_SCRIPTDIR)/logos.pl $< > $(FW_OBJ_DIR)/$<.mm$(ECHO_END)
	$(ECHO_COMPILING)$(TARGET_CXX) -c $(ALL_CFLAGS) $(ALL_OBJCFLAGS) $(ALL_OBJCCFLAGS) $(FW_OBJ_DIR)/$<.mm -o $@$(ECHO_END)
	$(ECHO_NOTHING)rm $(FW_OBJ_DIR)/$<.mm$(ECHO_END)

%.mm: %.l.mm
	$(FW_SCRIPTDIR)/logos.pl $< > $@

%.mm: %.xmm
	$(FW_SCRIPTDIR)/logos.pl $< > $@

%.mm: %.xm
	$(FW_SCRIPTDIR)/logos.pl $< > $@

%.m: %.xm
	$(FW_SCRIPTDIR)/logos.pl $< > $@

ifneq ($(FW_BUILD_DIR),.)
$(FW_BUILD_DIR):
	@mkdir -p $(FW_BUILD_DIR)
endif

$(FW_OBJ_DIR):
	@cd $(FW_BUILD_DIR); mkdir -p $(FW_OBJ_DIR_NAME)

Makefile: ;
framework/makefiles/*.mk: ;
$(FW_MAKEDIR)/*.mk: ;
$(FW_MAKEDIR)/master/*.mk: ;
$(FW_MAKEDIR)/instance/*.mk: ;
$(FW_MAKEDIR)/platform/*.mk: ;

endif

# TODO MAKE A BUNCH OF THINGS PHONY
