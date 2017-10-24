.PHONY: help

JS_FILES = index.js
ELM_FILES = $(shell find "src" -type f -name '*.elm')

lint-js: $(JS_FILES) ## Check javascript file for linter warnings
	@mkdir -p linter-logs
	@set -o pipefail \
	&& ./node_modules/eslint/bin/eslint.js $(JS_FILES) | tee linter-logs/js.log

lint-js-fix: $(JS_FILES) ## Check javascript file for linter warnings and fix if possible
	./node_modules/eslint/bin/eslint.js $(JS_FILES) --fix

build: $(ELM_FILES)
	elm-make src/Main.elm --output build/elm.js

dist: $(ELM_FILES)
	elm-make src/Main.elm --output dist/elm.js


gentest: dist
	cd example && node ../extractor.js -l De,En -s --root src

imptest: dist
	cd example && node ../extractor.js --format CSV --language En --importOutput src/ --import languages/en.csv

test: ## Run tests
	./node_modules/elm-test/bin/elm-test


help: ## Prints a help guide
	@echo "Available tasks:"
	@grep -E '^[\%a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	.PHONY: test
