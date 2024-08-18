LANG ?= en

.PHONY: set-lang
set-lang:
	@:

.PHONY: copy-infra
copy-infra:
	mkdir -p _build/$(LANG)
	cp -r data _build/$(LANG)
	cp -r docs _build/$(LANG)
	cp -r src _build/$(LANG)
	cp -r static _build/$(LANG)
	cp babel.config.js _build/$(LANG)
	cp package.json _build/$(LANG)
	cp yarn.lock _build/$(LANG)

.PHONY: build
build: copy-infra
	cd _build/$(LANG) && \
	yarn build && \
	mv build v0.2 && \
	mkdir build && \
	mv v0.2 build && \
	mv build/v0.2/404.html build

%:
	@:
