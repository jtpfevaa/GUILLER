all: mp4 window comet asteroide

clean:
	rm -rf mp4
	rm -rf gif
	rm -rf /tmp/gifs7
	
mp4files:
	make_video.sh -f -s mp4.* -e mp4 -d 10 gifs7.webm

window:
	make_video.sh -s wind.* -c 0xb3e04a -F 5% -e gif gifs7.webm
	
comet:
	make_video.sh -s comet.* -F 50% -e gif -d 4 gifs7.webm
	make_video.sh -s comet.* -F 50% -e mp4 -d 4 gifs7.webm

asteroide:
	make_video.sh -s asteroide.* -d 4 -F 30% -e mp4 gifs7.webm
	make_video.sh -s asteroide.* -d 4 -F 30% -e gif gifs7.webm
