BUILD_DIR=./build

BROWSERIFY=./node_modules/browserify/bin/cmd.js
TSC=./node_modules/typescript/bin/tsc

#build/%.js: src/%.ts
#	$(TSC) --module commonjs --target ES5 $< --outDir $(dir $@)

SOURCES:=$(wildcard src/core/*.ts) $(wildcard src/view/*.ts)
.PHONY: js
js: $(SOURCES)
	$(TSC) --module commonjs --target ES5 src/youclid.ts --outDir $(BUILD_DIR)

.DEFAULT_GOAL := bundle
.PHONY: bundle
bundle: js
	$(BROWSERIFY) -o static/js/youclid.js -r $(BUILD_DIR)/youclid.js:youclid

.PHONY: setup
setup:
	npm install
	./node_modules/tsd/build/cli.js query jquery underscore --action install

#.PHONY: clean
#clean:

