
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

webm: aterrizaje-wave.webm takeoff-wave.webm

aterrizaje-wave.webm: aterrizaje-wave.mp4
	ffmpeg -i $< -vf colorkey=0xb2d445:0.1:0.0 $@

takeoff-wave.webm: takeoff-wave.mp4
	ffmpeg -i $< -vf colorkey=0xb2d445:0.1:0.0 $@

