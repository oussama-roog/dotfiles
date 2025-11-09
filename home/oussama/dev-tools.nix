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
    nixd
    sass
    sqls

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
    sqlfluff
    sql-formatter

    shellcheck
    nodePackages.jsonlint
    htmlhint
    stylelint
    yamllint
    markdownlint-cli
    statix
  ];
}
