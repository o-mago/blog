build:
	hugo build --minify
	echo "blog.o-mago.com" > docs/CNAME
	@echo "Build complete"
