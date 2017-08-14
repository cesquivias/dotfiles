OUT ?= ~
BACKUP ?= $(OUT)/backups

SSH_KEYS = gh bb

UNAME = $(shell uname -o 2> /dev/null || uname -s)
HOSTNAME = $(shell hostname)

configs := $(notdir $(wildcard configs/*) $(wildcard $(UNAME)/configs/*))
out_configs := $(addprefix $(OUT)/., $(configs))
dirs := $(OUT) $(BACKUP) $(shell cat $(UNAME)/dirs 2> /dev/null) $(OUT)/.bin \
	 $(OUT)/.ssh $(OUT)/.ssh/keys $(OUT)/.config/fish/functions
bins := $(patsubst $(UNAME)/bins/%, $(OUT)/.bin/%, $(wildcard $(UNAME)/bins/*))
fish_functions := $(patsubst fish/%, $(OUT)/.config/fish/%, $(shell find fish -type f)) 
# TODO : back up fish and ssh config files
backups := $(addprefix $(BACKUP)/., $(configs))

all: $(out_configs) \
	$(bins) \
	$(fish_functions) \
	$(OUT)/.ssh/config \
	$(patsubst %, $(OUT)/.ssh/keys/%, $(SSH_KEYS))

backup: $(backups) | $(BACKUP)

clean:
	rm -f $(out_configs)
	rm -rf ~/.config/fish/functions
	rm -ri ~/.ssh

$(OUT)/.%: configs/% | $(OUT)
	ln -s $(abspath $<) $@

$(OUT)/.%: $(UNAME)/configs/%
	ln -s $(abspath $<) $@

/home/${USER}:
	ln -s ~ $@

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
	ln -s $(abspath $<) $@

$(OUT)/.bin/%: $(UNAME)/bins/% | $(OUT)/.bin
	ln -s $(abspath $<) $@

$(BACKUP)/%:
	$(if $(wildcard $(OUT)/$*), mv $(OUT)/$* $@)

.PHONY: all backup clean
