CONFIGS = hgrc gitconfig bash_profile bashrc bash_aliases \
	bash_functions Xdefaults screenrc ssh/config

FISH_FUNCTIONS := $(wildcard fish_functions/*.fish)

UNAME = $(shell uname -o 2> /dev/null || uname -s)
ifeq ($(UNAME),Cygwin)
CONFIGS += startxwinrc
endif

all: $(patsubst %, ~/.%, $(CONFIGS)) \
	$(patsubst fish_functions/%, ~/.config/fish/functions/%, $(FISH_FUNCTIONS))

clean:
	rm -f $(patsubst %, ~/.%, $(CONFIGS))
	rm -rf ~/.config/fish/functions
	rm -ri ~/.ssh

~/.%: configs/%
	ln -s $(abspath $<) $@

/home/%:
	ln -s ~ $@

~/.ssh/keys:
	mkdir -p $@

~/.ssh/config: | ~/.ssh/keys /home/$(USER)
	cp configs/ssh/config $@
	setfacl -b $@
	chgrp Users $@
	chmod 0600 $@

~/.config/fish/functions:
	mkdir -p $@

~/.config/fish/functions/%: fish_functions/% | ~/.config/fish/functions
	cp $< $@

.PHONY: all clean
