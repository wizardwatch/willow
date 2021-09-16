if [ ! -d /home/wyatt/Pictures/$(date +"%Y-%m-%d") ]; then mkdir -p /home/wyatt/Pictures/$(date +"%Y-%m-%d"); fi
grim -g "$(slurp)" - | tee /home/wyatt/Pictures/$(date +"%Y-%m-%d")/$(date +'%H%M%S-%Y-%m-%d.png')
