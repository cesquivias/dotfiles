OUT ?= ~
BACKUP ?= $(OUT)/backups

SSH_KEYS = gh bb

FISH_FUNCTIONS := $(wildcard fish_functions/*.fish)

UNAME = $(shell uname -o 2> /dev/null || uname -s)
HOSTNAME = $(shell hostname)

configs = $(patsubst configs/%, $(OUT)/.%, $(wildcard configs/*))
configs += $(patsubst $(UNAME)/configs/%, $(OUT)/.%, $(wildcard $(UNAME)/configs/*))
dirs := $(shell cat $(UNAME)/dirs 2> /dev/null) $(BACKUP) $(OUT)/.bin \
	 $(OUT)/.ssh $(OUT)/.ssh/keys $(OUT)/.config/fish/functions
bins = $(patsubst $(UNAME)/bins/%, $(OUT)/.bin/%, $(wildcard $(UNAME)/bins/*))

all: $(configs) \
	$(bins) \
	$(patsubst fish_functions/%, $(OUT)/.config/fish/functions/%, $(FISH_FUNCTIONS)) \
	$(OUT)/.ssh/config \
	$(patsubst %, $(OUT)/.ssh/keys/%, $(SSH_KEYS))

clean:
	rm -f $(configs)
	rm -rf ~/.config/fish/functions
	rm -ri ~/.ssh

$(OUT)/.%: configs/% | $(BACKUP)
	-mv -f $@ $(BACKUP)
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

$(OUT)/.config/fish/functions/%: fish_functions/% | $(OUT)/.config/fish/functions
	cp $< $@

$(OUT)/.bin/%: $(UNAME)/bins/% | $(OUT)/.bin
	ln -s $(abspath $<) $@

.PHONY: all clean
