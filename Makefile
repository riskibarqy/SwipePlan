FLUTTER ?= flutter
DEVICE ?=
GIT ?= git
TAG_PREFIX ?= v
VERSION ?=
LATEST_TAG := $(shell $(GIT) describe --tags --match "$(TAG_PREFIX)*" --abbrev=0 2>/dev/null)
NEXT_TAG := $(if $(VERSION),$(TAG_PREFIX)$(VERSION),$(shell TAG_PREFIX="$(TAG_PREFIX)" LATEST_TAG="$(LATEST_TAG)" python3 tooling/next_tag.py))

.PHONY: setup pubget run analyze format test build-apk build-ios clean ensure-clean app-publish

setup: pubget

pubget:
	$(FLUTTER) pub get

run:
	$(FLUTTER) run $(if $(DEVICE),-d $(DEVICE),)

analyze:
	$(FLUTTER) analyze

format:
	$(FLUTTER) format lib

test:
	$(FLUTTER) test

build-apk:
	$(FLUTTER) build apk

build-ios:
	$(FLUTTER) build ios

clean:
	$(FLUTTER) clean

ensure-clean:
	@if ! $(GIT) diff --quiet --ignore-submodules HEAD; then \
	  echo "Working tree has uncommitted changes. Please commit or stash before publishing."; \
	  exit 1; \
	fi

app-publish: ensure-clean test
	@if [ -z "$(NEXT_TAG)" ]; then \
	  echo "Unable to determine next tag"; \
	  exit 1; \
	fi
	@echo "Tagging release $(NEXT_TAG)"
	$(GIT) tag -a $(NEXT_TAG) -m "Release $(NEXT_TAG)"
	$(GIT) push origin $(NEXT_TAG)
