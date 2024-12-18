OUT ?= ~
BACKUP ?= $(OUT)/backups

SSH_KEYS = gh bb

# The name of the platform (e.g., Cygwin, Darwin)
UNAME := $(shell uname -o 2> /dev/null || uname -s)
HOSTNAME := $(shell hostname)

# Files to put in home dir. Prefix with a '.'
home := $(notdir $(wildcard home/*) $(wildcard $(UNAME)/home/*))
out_home := $(addprefix $(OUT)/., $(home))

# Files to put in ~/.config dir
configs := $(notdir $(wildcard config/*) $(wildcard $(UNAME)/config/*))
out_configs := $(addprefix $(OUT)/.config/, $(configs))

# Directories required to exist
dirs := $(OUT) $(BACKUP) $(shell cat $(UNAME)/dirs 2> /dev/null) $(OUT)/.bin \
	 $(OUT)/.ssh $(OUT)/.ssh/keys \
	 $(OUT)/.config $(OUT)/.config/fish/functions \
	 $(BACKUP)/.config/fish/functions
# Executables to put in ~/.bin
bins := $(patsubst $(UNAME)/bins/%, $(OUT)/.bin/%, $(wildcard $(UNAME)/bins/*))
fish_functions := $(patsubst fish/%, $(OUT)/.config/fish/%, $(shell find fish -type f))

# Now with my understanding of make, this should be the generic place to put all files in the future
out_files := $(patsubst $(UNAME)/out/%, $(OUT)/%, $(shell find $(UNAME)/out/ -type f))

# TODO : back up fish and ssh config files
backups := $(BACKUP)/.ssh $(BACKUP)/.config/fish $(addprefix $(BACKUP)/., $(home))

LN = ln -f -s

all: $(out_home) \
	$(out_configs) \
	$(out_files) \
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

$(OUT)/.config/%: config/% | $(OUT)/.config
	$(LN) $(abspath $<) $@

$(OUT)/.config/%: $(UNAME)/config/%
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

$(OUT)/%.plist: $(UNAME)/out/%.plist
	cp $(abspath $<) $@
	plutil -convert binary1 $@

$(OUT)/%: $(UNAME)/out/%
	$(LN) $(abspath $<) $@

$(BACKUP)/%: | $(BACKUP) $(BACKUP)/.config/fish/functions
	$(if $(wildcard $(OUT)/$*), cp -r $(OUT)/$* $@)

.PHONY: all backup clean
