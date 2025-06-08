{ config ? {}, pkgs ? {}, lib ? {}, hyprland ? {}, home-manager ? {}, ... }@args:
let 
defaultSettings = {
      decoration = {
        shadow_offset = "0 5";
        "col.shadow" = "rgba(00000099)";
      };
      "$mod" = "ALT";
      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
};
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = defaultSettings // (args.settings or {});
  };
}