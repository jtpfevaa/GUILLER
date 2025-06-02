
all: clean allphotos

allphotos:
	make -C ../IMG-2 clean
	make -C ../IMG-2
	checkStars.js --origin ../IMG-2/ --input ../scripts/stars.js --target photos
	make sizeImg.js

sizeImg.js: photos/$(wildcard *.png *.jpg)
	./sizeimg.sh photos > photos/sizeImg.js

clean: 
	rm -rf photos
	mkdir photos
