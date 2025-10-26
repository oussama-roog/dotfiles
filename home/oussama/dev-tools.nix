{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lua-language-server
    typescript-language-server
    gopls
    vscode-langservers-extracted
    tailwindcss-language-server
    angular-language-server
    pyright
    clang-tools
    bash-language-server
    nil
    
    nodePackages.prettier
    stylua
    eslint_d
    ruff
    black
    shfmt
    golangci-lint
    gofumpt
    golines
    goimports-reviser
    nixpkgs-fmt
    
    shellcheck
    nodePackages.jsonlint
    htmlhint
    stylelint
    yamllint
    markdownlint-cli
    statix
  ];
}
