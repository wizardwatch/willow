{pkgs, config, ...}:{
  services = {
    #mosquitto = {
    #  enable = true;
    #};
    home-assistant = {
      enable = true;
      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          time_zone = "UTC";
        };
        frontend = {
          themes = "!include_dir_merge_named themes";
        };
        http = {};
        mqtt = {
          broker = "localhost";
          discovery = true;
        };
        influxdb = {
          username = "homeassistant";
          host = "influxdb.thalheim.io";
          password = "not_a";
          database = "homeassistant";
          ssl = true;
          include.entities = [
            "person.jorg_thalheim"
            "person.shannan_lekwati"
            "device_tracker.beatrice"
            "device_tracker.android"
          ];
        };
        feedreader.urls = [ "https://nixos.org/blogs.xml" ];
      };
      extraComponents = [
        "mqtt"
        "influxdb"
        "esphome"
        "met"
      ];
    };
  };
}
