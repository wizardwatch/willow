---
title: starship.nix
---
```nix
{pkgs, config, ...}:
{
  programs.starship =  {
    enable = true;
    enableZshIntegration = true;

  };
}
```
