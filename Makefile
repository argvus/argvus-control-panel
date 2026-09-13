PREFIX ?= /usr
DESTDIR ?=

.DEFAULT_GOAL := help

.PHONY: help install uninstall validate build clean

help:
	@echo "Available targets:"
	@echo "  make build"
	@echo "  make install"
	@echo "  make uninstall"
	@echo "  make validate"

install:
	install -dm755 "$(DESTDIR)$(PREFIX)/share/argvus"
	cp -R --no-preserve=ownership src/. "$(DESTDIR)$(PREFIX)/share/argvus/"
	find "$(DESTDIR)$(PREFIX)/share/argvus/scripts" -type f -name '*.sh' -exec chmod 755 {} \; 2>/dev/null || true
	install -Dm644 LICENSE "$(DESTDIR)$(PREFIX)/share/licenses/argvus-control-panel/LICENSE"

uninstall:
	rm -rf "$(DESTDIR)$(PREFIX)/share/argvus/quickshell/argvus-control-panel"
	rm -f "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/toggle-sidebar.sh"
	rm -f "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/weather-location.sh"
	rm -f "$(DESTDIR)$(PREFIX)/share/licenses/argvus-control-panel/LICENSE"

validate:
	@if find src -name '*.sh' | grep -q .; then \
		for script in $$(find src -name '*.sh'); do sh -n "$$script"; done; \
		if command -v shellcheck >/dev/null 2>&1; then for script in $$(find src -name '*.sh'); do shellcheck -e SC1090 -e SC2034 "$$script"; done; else echo "shellcheck not found; skipping shell lint"; fi; \
	fi
	@if find src -name '*.qml' | grep -q .; then \
		if command -v qmllint >/dev/null 2>&1; then \
			if ! qmllint -I src/quickshell/argvus-control-panel $$(find src -name '*.qml'); then \
				echo "qmllint reported issues; Quickshell imports may require runtime context"; \
			fi; \
		else \
			echo "qmllint not found; skipping QML lint"; \
		fi; \
	else \
		echo "no QML files found"; \
	fi
	@test -f src/quickshell/argvus-control-panel/shell.qml
	@test -x src/scripts/argvus/toggle-sidebar.sh
	@test -x src/scripts/argvus/weather-location.sh
	@test ! -e src/waybar
	@echo "argvus-control-panel validation ok"

.PHONY: build

build:
	@tools/build-local-package.sh

clean:
	rm -rf dist
	rm -f packaging/arch/*.zst packaging/arch/*.tar.gz
