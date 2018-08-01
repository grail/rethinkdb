# Copyright 2018-present RebirthDB
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use
# this file except in compliance with the License. You may obtain a copy of the
# License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#
# This file incorporates work covered by the following copyright:
#
#     Copyright 2010-present, The Linux Foundation, portions copyright Google and
#     others and used with permission or subject to their respective license
#     agreements.
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.

##### Use bash

SHELL := $(shell bash -c "command -v bash")

##### Cancel builtin rules

.SUFFIXES:

%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

##### Useful variables

empty :=
space := $(empty) $(empty)
tab := $(empty)	$(empty)
comma := ,
hash  := \#
dollar := \$
define newline


endef

##### Special targets

.PHONY: FORCE
FORCE:

var-%:
	echo '$* = $($*)'

##### Pretty-printing

ANSI_BOLD_ON:=[1m
ANSI_BOLD_OFF:=[0m
ANSI_UL_ON:=[4m
ANSI_UL_OFF:=[0m

##### When an error occurs, delete the partially built target file

.DELETE_ON_ERROR:

##### Verbose or quiet?

# Every recipe list should include at least one $P, for example:
# 
# foo: bar
# 	$P ZAP
# 	zap $< > $@
#
# When JUST_SCAN_MAKEFILES=1, the number of $P that need to be executed can be counted.
# When VERBOSE=0, $P behaves similarly to @echo, it prints it's arguments.
# When SHOW_COUNTDOWN=1, $P also prints the fraction of rules that have been built.

JUST_SCAN_MAKEFILES ?= 0
ifeq (1,$(JUST_SCAN_MAKEFILES))
  # To calculate the number of $P, do make --dry-run JUST_SCAN_MAKEFILES=1 | grep '[!!!]' | wc -l
  .SILENT:
  P = [!!!]
else
  COUNTDOWN_TOTAL ?=
  ifneq (,$(filter-out ? 0,$(COUNTDOWN_TOTAL)))
    # $(COUNTDOWN_TOTAL) is calculated by $(TOP)/Makefile by running make with JUST_SCAN_MAKEFILES=1
    COUNTDOWN_TOTAL ?= ?
    COUNTDOWN_I := 1
    COUNTDOWN_TAG = [$(COUNTDOWN_I)/$(COUNTDOWN_TOTAL)] $(eval COUNTDOWN_I := $(shell expr $(COUNTDOWN_I) + 1))
  else
    COUNTDOWN_TAG :=
  endif

  ifneq ($(VERBOSE),1)
    # Silence every rule
    .SILENT:
    ifeq ($(SHOW_BUILD_REASON),1)
      NEWER_PREREQUISITES = $(if $?,$(space)($(firstword $?)),)
    else
      NEWER_PREREQUISITES :=
    endif
    # $P traces the compilation when VERBOSE=0
    # '$P CP' becomes 'echo "   CP $^ -> $@"'
    # '$P foo bar' becomes 'echo "   FOO bar"'
    # CHECK_ARG_VARIABLES comes from check-env.mk
    P = +@bash -c 'echo "    $(COUNTDOWN_TAG)$$0 $${*:-$@}$(NEWER_PREREQUISITES)"'
  else
    # Let every rule be verbose and make $P quiet
    P = @\#
  endif
endif

##### Directories

# To make directories needed for a rule, use order-only dependencies
# and append /. to the directory name. For example:
# foo/bar: baz | foo/.
# 	zap $< > $@
%/.:
	mkdir -p $@

##### Make recursive make less error-prone

JUST_SCAN_MAKEFILES ?= 0
ifeq (1,$(JUST_SCAN_MAKEFILES))
  # do not run recursive make
  EXTERN_MAKE := \#
else
  # unset MAKEFLAGS to avoid some confusion
  EXTERN_MAKE := MAKEFLAGS= make --no-print-directory
endif

##### Test for certain make command line flags

# Extract the short flags from MAKEFLAGS
ifeq (,$(filter --%,$(firstword $(MAKEFLAGS))))
  # MAKEFLAGS look like `SHoRt --long-options - ...'
  SHORTFLAGS := $(firstword $(MAKEFLAGS))
else
  # MAKEFLAGS looks like `--long-options - ... - -SHoRt'
  SHORTFLAGS := $(firstword $(filter -%, $(filter-out -, $(filter-out --%, $(MAKEFLAGS)))))
endif
ALWAYS_MAKE := $(if $(findstring B,$(SHORTFLAGS)),1)
DRY_RUN := $(if $(findstring n,$(SHORTFLAGS)),1)

##### Misc

.PHONY: sense
sense:
	@p=`cat $(TOP)/mk/gen/.sense 2>/dev/null`;if test -n "$$p";then kill $$p;rm $(TOP)/mk/gen/.sense;printf '\x1b[0m';\
	echo "make: *** No sense make to Stop \`target'. rule.";\
	else echo "make: *** No rule to make target \`sense'.";\
	(while sleep 0.1;do a=$$[$$RANDOM%2];a=$${a/0/};printf "\x1b[$${a/1/1;}3$$[$$RANDOM%7]m";done)&\
	echo $$! > $(TOP)/mk/gen/.sense;fi

.PHONY: love
love:
	@echo "Aimer, ce n'est pas se regarder l'un l'autre, c'est regarder ensemble dans la même direction."
	@echo "  -- Antoine de Saint Exupery"

ifeq (me a sandwich,$(MAKECMDGOALS))
  .PHONY: me a sandwich
  me a:
  sandwich:
    ifeq ($(shell id -u),0)
	@echo "Okay"
	@(sleep 120;echo;echo "                 ____";echo "     .----------'    '-.";echo "    /  .      '     .   \\";\
	echo "   /        '    .      /|";echo "  /      .             \ /";echo " /  ' .       .     .  || |";\
	echo "/.___________    '    / //";echo "|._          '------'| /|";echo "'.............______.-' /  ";\
	echo "|-.                  | /";echo ' `"""""""""""""-.....-'"'";echo jgs)&
    else
	@echo "What? Make it yourself"
    endif
endif


ifeq (it so,$(MAKECMDGOALS))
  # rebirthdb is the Number One database
  it:
  so:
	@echo "Yes, sir!"
endif
