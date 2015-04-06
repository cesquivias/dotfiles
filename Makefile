CONFIGS = .hgrc .gitconfig .bash_profile .bashrc .bash_aliases \
	.bash_functions .Xdefaults .screenrc

FISH_FUNCTIONS := $(wildcard fish_functions/*.fish)

UNAME = $(shell uname -o 2> /dev/null || uname -s)
ifeq ($(UNAME),Cygwin)
CONFIGS += .startxwinrc ~/.ssh/config
endif

all: $(patsubst .%, ~/.%, $(CONFIGS)) \
	$(patsubst fish_functions/%, ~/.config/fish/functions/%, $(FISH_FUNCTIONS))

clean:
	rm -f $(patsubst %, ~/%, $(CONFIGS))
	rm -rf ~/.config/fish/functions

~/%: %
	ln -s $(abspath $<) $@

/home/%:
	ln -s ~ $@

~/.ssh/keys:
	mkdir -p $@

~/.ssh/config: | ~/.ssh/keys /home/$(USER)
	touch $@
	setfacl -b $@
	chgrp Users $@
	chmod 0600 $@

~/.config/fish/functions:
	mkdir -p $@

~/.config/fish/functions/%: fish_functions/% | ~/.config/fish/functions
	cp $< $@

.PHONY: all clean
