OUT ?= ~
BACKUP ?= $(OUT)/backups

SSH_KEYS = gh bb

FISH_FUNCTIONS := $(wildcard fish_functions/*.fish)

UNAME = $(shell uname -o 2> /dev/null || uname -s)
HOSTNAME = $(shell hostname)

configs = $(patsubst configs/%, $(OUT)/.%, $(wildcard configs/*))
configs += $(patsubst $(UNAME)/configs/%, $(OUT)/.%, $(wildcard $(UNAME)/configs/*))
dirs := $(shell cat $(UNAME)/dirs 2> /dev/null) $(BACKUP) $(OUT)/.bin \
	 $(OUT)/.ssh/keys $(OUT)/.config/fish/functions
bins = $(patsubst $(UNAME)/bins/%, $(OUT)/.bin/%, $(wildcard $(UNAME)/bins/*))

all: $(configs) \
	$(bins) \
	$(patsubst fish_functions/%, ~/.config/fish/functions/%, $(FISH_FUNCTIONS)) \
	$(OUT)/.ssh/config \
	$(patsubst %, ~/.ssh/keys/%, $(SSH_KEYS)) \
	| $(dirs)

clean:
	rm -f $(configs)
	rm -rf ~/.config/fish/functions
	rm -ri ~/.ssh

~/.%: configs/% | $(BACKUP)
	-mv -f $@ $(BACKUP)
	ln -s $(abspath $<) $@

/home/%:
	ln -s ~ $@

$(dirs):
	mkdir -p $@

~/.ssh/config: | ~/.ssh/keys
	cp configs/ssh/config $@
ifeq ($(UNAME),Cygwin)
	setfacl -b $@
	chgrp Users $@
endif
	chmod 0600 $@

~/.ssh/keys/%: | ~/.ssh/keys
	ssh-keygen -q -t rsa -C $(USER)@$(HOSTNAME) -f $@
	chmod -w $@ $@.pub

~/.config/fish/functions/%: fish_functions/%
	cp $< $@

~/.bin/%: $(UNAME)/bins/%
	ln -s $(abspath $<) $@

.PHONY: all clean
