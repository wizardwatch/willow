{ pkgs, conf, ... }:
{
  programs.ncmpcpp = {
    enable = true;
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };
    bindings = [ ];
    settings = {
      visualizer_data_source = "/tmp/mpd.fifo";
      visualizer_output_name = "my_fifo";
      visualizer_in_stereo = "yes";
      visualizer_type = "ellipse";
      visualizer_look = "+|";
    };
  };
}
