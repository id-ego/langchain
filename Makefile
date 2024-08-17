.PHONY: build
build:
	rm -rf build
	NODE_OPTIONS='--max-old-space-size=8192' yarn build
	mv build v0.2
	mkdir build
	mv v0.2 build
	mv build/v0.2/404.html build
