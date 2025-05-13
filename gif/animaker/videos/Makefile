
all: 
	make_video.sh -f -c 0xB2D445 -e gif mip1.mp4
	make_video.sh -f -c 0xB2D445 -e gif mip2.mp4
	make_video.sh -f -c 0xB2D445 -e gif mip3.mp4
	make_video.sh -f -c 0xB2D445 -e gif mip4.mp4
	make_video.sh -f -c 0xB2D445 -e gif mip5.mp4

clean: 
	rm -r gif
	rm aterrizaje-wave.webm takeoff-wave.webm

gifs3:
	make_video.sh -c 0xB2D445 -e gif gifs3.webm

gifs4:
	make_video.sh -c 0xB2D445 -e gif gifs4.webm

gifs5: gifs5a gifs5b

gifs5a:
	make_video.sh -c 0xB3df4a -e gif gifs5a.webm
gifs5b:
	make_video.sh -e webm gifs5b.webm

gifs5a.webm: gifs5.webm
	ffmpeg -i $< -ss 00:00:21 -to 00:00:22 -c copy $@

gifs5b.webm: gifs5.webm
	ffmpeg -i $< -ss 00:00:21 -c:v libvpx-vp9 $@

gifs6:
	make_video.sh -c 0xB3df4a -e gif gifs6.webm

gif/gifs6_wave_rep5.png: gif/gifs6_wave-SR.gif
	convert $(shell yes $< | head -n 6) -trim +append $@

gif/ola-larga.gif: gif/gifs6_wave_rep5.png
	mov-hola.sh -w 500 -I 115 -o $@ $< 


webm: aterrizaje-wave.webm takeoff-wave.webm

aterrizaje-wave.webm: aterrizaje-wave.mp4
	ffmpeg -i $< -vf colorkey=0xb2d445:0.1:0.0 $@

takeoff-wave.webm: takeoff-wave.mp4
	ffmpeg -i $< -vf colorkey=0xb2d445:0.1:0.0 $@

frog:
	make_video.sh -c 0xffffff -s frog -d 30 -e gif frog_jumps.gif

flash_pet: gifs3_dogwalk-SR.png gifs6_cat-SR.png gifs6_alien2-SR.png
	flash_gif.sh -M 8 -m 5 -f flash_pet.gif gifs3_dogwalk-SR.png gifs6_cat-SR.png gifs6_alien2-SR.png

petmanSS: flash_pet.gif
	quitar_silueta_gif.sh gif/gifs6_petmn-SR.gif petmn-SS.gif msk_pet.png 

