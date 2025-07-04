build:
	hugo build --minify
	rm -rf docs/*
	#create a CNAME file
	echo "blog.o-mago.com" > docs/CNAME
	mv public/* docs/
	@echo "Build complete"