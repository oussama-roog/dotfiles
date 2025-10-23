{ config, pkgs, ... }:
let
	dotfiles = "${config.home.homeDirectory}/dotfiles/.config";
	create_symlinks = paht: config.lib.file.mkOutOfStoreSymlink path;
	configs= {
		hyprland = "hyprland";
		nvim = "nvim";
		waybar = "waybar";
		rofi = "rofi";
	}
in
{
	home.username = "oussama";
	home.homeDirectory = "/home/oussama";
	home.stateVersion = "25.05";
	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo nixos and neovim btw";
		};
		profileExtra = ''
			if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
				exec hyprland
			fi
		'';
	};
	programs.git = {
		enable = true;
		userEmail = "oussamaroog@gmail.com";
		userName = "oussama-roog";
		extraConfig = {
			init.defaultBranch = "main";
		};
	};
	
	xdg.configFile = builtins.mapAttrs ( name: subpath: {
		source = create_symlink "${dotfiles}/${subpath}";
		recursive = true;
	}) configs;

	home.packages = with pkgs; [
		nodejs
	];

}
