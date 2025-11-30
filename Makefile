FLUTTER ?= flutter
DEVICE ?=

.PHONY: setup pubget run analyze format test build-apk build-ios clean

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
