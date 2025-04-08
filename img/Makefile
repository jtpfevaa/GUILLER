
all: sizeImg.js

sizeImg.js: photos/$(wildcard *.png *.jpg)
	./sizeimg.sh photos > photos/sizeImg.js

clean: 
	rm photos/sizeImg.js
