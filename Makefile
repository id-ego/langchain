.PHONY: copy-infra
copy-infra:
	mkdir -p build
	cp -r data build
	cp -r docs build
	cp -r src build
	cp -r static build
	cp babel.config.js build
	cp package.json build
	cp yarn.lock build

.PHONY: build
build: copy-infra
	cp _build/en/* build
	cd build
	yarn build
	mv build v0.2
	mkdir build
	mv v0.2 build
	mv build/v0.2/404.html build
	mv build ../_build/en
