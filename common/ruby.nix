{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    #(ruby_3_0.override{jitSupport = true; # I don't really want to compile ruby
    ruby_3_0
    bundix
    rubyPackages_3_0.solargraph
  ];
}
