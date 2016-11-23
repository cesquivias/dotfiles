CONFIGS = hgrc gitconfig bash_profile bashrc bash_aliases \
	bash_functions Xdefaults screenrc ssh/config
BACKUP = ~/backups
DIRS=$(BACKUP) ~/.bin
BIN =

SSH_KEYS = gh bb

FISH_FUNCTIONS := $(wildcard fish_functions/*.fish)

UNAME = $(shell uname -o 2> /dev/null || uname -s)
HOSTNAME = $(shell hostname)

ifeq ($(UNAME),Cygwin)
CONFIGS += startxwinrc
DIRS += /home/$(USER)
endif

ifeq ($(UNAME),Darwin)
BIN += emacs emacsclient
endif

all: $(patsubst %, ~/.%, $(CONFIGS)) \
	$(patsubst fish_functions/%, ~/.config/fish/functions/%, $(FISH_FUNCTIONS)) \
	$(patsubst %, ~/.ssh/keys/%, $(SSH_KEYS)) \
	$(patsubst %, ~/.bin/%, $(BIN)) \
	| $(DIRS)

clean:
	rm -f $(patsubst %, ~/.%, $(CONFIGS))
	rm -rf ~/.config/fish/functions
	rm -ri ~/.ssh

~/.%: configs/% | $(BACKUP)
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

.PHONY: all clean
