.PHONY: build
build:
	yarn build
	mv build ko
	mkdir -p build/v0.2
	mv ko build/v0.2
	mv build/v0.2/ko/404.html build
