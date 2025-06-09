{
  pkgs,
  inputs,
  ...
}: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "redoak" = {
        hostname = "172.28.0.156";
        user = "willow";
      };
    };
  };
}