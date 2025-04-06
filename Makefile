
scriptsdir = /usr/share/stellarium/scripts

all: img/sizeImg.js
clean:
	make -C img clean

img/sizeImg.js: 
	make -C img sizeImg.js
