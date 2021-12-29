```nix{ config, pkgs, ... }:{
	services = {
                xserver = {
			windowManager.qtile.enable = true;
		};
	};
}
```
