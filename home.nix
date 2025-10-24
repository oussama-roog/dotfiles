{ config, pkgs, system, inputs, unstable, ... }:
let
	dotfiles = "${config.home.homeDirectory}/dotfiles/.config";
	create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
	configs= {
		hypr = "hypr";
		nvim = "nvim";
		waybar = "waybar";
		rofi = "rofi";
        ghostty = "ghostty";
        yazi = "yazi";
        lazygit = "lazygit";
	};
in
{
	home.username = "oussama";
	home.homeDirectory = "/home/oussama";
	home.stateVersion = "25.05";
	
	dconf.settings = {
		"org/gnome/desktop/interface" = {
			color-scheme = "prefer-dark";
		};
	};
	
	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo nixos and neovim btw";
		};
		profileExtra = ''
			if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
				exec hyprland
			fi
            
            export PATH=/home/oussama/.opencode/bin:$PATH
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
        unstable.opencode
        inputs.zen-browser.packages."${system}".beta
    ];

}
