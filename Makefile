export RSYNC_ROOT=$(PWD)

TEST_DIR := $(RSYNC_ROOT)/tests/rsync/
MINIMAL_PATH := $(RSYNC_ROOT)/scripts/minimal.vim
MINIMAL_INIT_PATH := $(RSYNC_ROOT)/tests/minimal_init.lua

UNAME_S := $(shell uname -s)

.PHONY: lint
lint: stylua luacheck

.PHONY: luacheck
luacheck:
	luacheck lua/rsync

.PHONY: stylua
stylua:
	stylua --color always --check lua/ tests/

.PHONY: plenary
plenary:
	if [ -d plenary.nvim ]; then cd plenary.nvim && git pull; \
		else git clone https://github.com/nvim-lua/plenary.nvim; fi

.PHONY: test
test: plenary
	nvim --headless --noplugin -u $(MINIMAL_PATH) -c "PlenaryBustedDirectory $(TEST_DIR) {minimal_init = '$(MINIMAL_INIT_PATH)'}"

.PHONY: test-clean
test-clean:
	@rm -rf luacov*
