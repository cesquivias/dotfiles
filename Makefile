OUT ?= ~
BACKUP ?= $(OUT)/backups

SSH_KEYS = gh bb

UNAME = $(shell uname -o 2> /dev/null || uname -s)
HOSTNAME = $(shell hostname)

home := $(notdir $(wildcard home/*) $(wildcard $(UNAME)/home/*))
out_home := $(addprefix $(OUT)/., $(home))
dirs := $(OUT) $(BACKUP) $(shell cat $(UNAME)/dirs 2> /dev/null) $(OUT)/.bin \
	 $(OUT)/.ssh $(OUT)/.ssh/keys $(OUT)/.config/fish/functions \
	 $(BACKUP)/.config/fish/functions
bins := $(patsubst $(UNAME)/bins/%, $(OUT)/.bin/%, $(wildcard $(UNAME)/bins/*))
fish_functions := $(patsubst fish/%, $(OUT)/.config/fish/%, $(shell find fish -type f)) 
# TODO : back up fish and ssh config files
backups := $(BACKUP)/.ssh $(BACKUP)/.config/fish $(addprefix $(BACKUP)/., $(home))

LN = ln -f -s

all: $(out_home) \
	$(bins) \
	$(fish_functions) \
	$(OUT)/.ssh/config \
	$(patsubst %, $(OUT)/.ssh/keys/%, $(SSH_KEYS))

backup: $(backups)

clean:
	$(RM) $(out_home)
	$(RM) $(fish_functions)
	$(if $(wildcard $(OUT)/.ssh), $(RM) -rdI $(OUT)/.ssh)

$(OUT)/.%: home/% | $(OUT)
	$(LN) $(abspath $<) $@

$(OUT)/.%: $(UNAME)/home/%
	$(LN) $(abspath $<) $@

$(dirs):
	mkdir -p $@

$(OUT)/.ssh/config: ssh/config | $(OUT)/.ssh
	cp $< $@
ifeq ($(UNAME),Cygwin)
	setfacl -b $@
	chgrp Users $@
endif
	chmod 0600 $@

$(OUT)/.ssh/keys/%: | $(OUT)/.ssh/keys
	ssh-keygen -q -t rsa -C $(USER)@$(HOSTNAME) -f $@
	chmod -w $@ $@.pub

$(OUT)/.config/fish/%: fish/% | $(OUT)/.config/fish/functions
	$(LN) $(abspath $<) $@

$(OUT)/.bin/%: $(UNAME)/bins/% | $(OUT)/.bin
	$(LN) $(abspath $<) $@

$(BACKUP)/%: | $(BACKUP) $(BACKUP)/.config/fish/functions
	$(if $(wildcard $(OUT)/$*), cp -r $(OUT)/$* $@)

.PHONY: all backup clean
