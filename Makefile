CONFIGS = .hgrc .gitconfig .bash_profile .bashrc .bash_aliases \
	.bash_functions .Xdefaults .screenrc

UNAME = $(shell uname -o &> /dev/null || uname -s)
ifeq ($(UNAME),Cygwin)
	CONFIGS += .startxwinrc
endif

all: $(patsubst .%, ~/.%, $(CONFIGS))

clean:
	rm -f $(patsubst %, ~/%, $(CONFIGS))

~/%: %
	ln -s $(abspath $<) $@

.PHONY: all clean
