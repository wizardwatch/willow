{lib, ...}:
let
  menu = "wofi --show run -i";
  modifier = "Mod4";
in lib.mkOptionDefault{
  "${modifier}+x" = "kill";
  "${modifier}+n" = "${menu}";
  "${modifier}+c" = '' exec grim -g "$(slurp)" - | wl-copy '';
  "${modifier}+Shift+c" = '' mkdir -p /home/wyatt/Pictures/$(date +"%Y-%m-%d"); grim -g "$(slurp)" - | tee /home/wyatt/Pictures/$(date +"%Y-%m-%d")/$(date +'%H%M%S-%Y-%m-%d.png') '';

}
