OUT ?= ~

BACKUP = ~/backups
DIRS=$(BACKUP) ~/.bin

SSH_KEYS = gh bb

FISH_FUNCTIONS := $(wildcard fish_functions/*.fish)

UNAME = $(shell uname -o 2> /dev/null || uname -s)
HOSTNAME = $(shell hostname)

configs = $(patsubst configs/%, $(OUT)/.%, $(wildcard configs/*))
configs += $(patsubst $(UNAME)/configs/%, $(OUT)/.%, $(wildcard $(UNAME)/configs/*))

ifeq ($(UNAME),Cygwin)
DIRS += /home/$(USER)
endif

bins = $(patsubst $(UNAME)/bins/%, $(OUT)/.bin/%, $(wildcard $(UNAME)/bins/*))

all: $(configs) \
	$(bins) \
	$(OUT)/.ssh/config \
	$(patsubst fish_functions/%, ~/.config/fish/functions/%, $(FISH_FUNCTIONS)) \
	$(patsubst %, ~/.ssh/keys/%, $(SSH_KEYS)) \
	| $(DIRS)

clean:
	rm -f $(configs)
	rm -rf ~/.config/fish/functions
	rm -ri ~/.ssh

~/.%: configs/% | $(BACKUP) $(DIRS)
	-mv -f $@ $(BACKUP)
	ln -s $(abspath $<) $@

/home/%:
	ln -s ~ $@

$(BACKUP):
	mkdir -p $@

~/.bin:
	mkdir -p $@

~/.ssh/keys:
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

~/.config/fish/functions:
	mkdir -p $@

~/.config/fish/functions/%: fish_functions/% | ~/.config/fish/functions
	cp $< $@

~/.bin/%: mac/% | ~/.bin
	ln -s $(abspath $<) $@

~/.bin/%: $(UNAME)/bins/%
	ln -s $(abspath $<) $@

.PHONY: all clean
