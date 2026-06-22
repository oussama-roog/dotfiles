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
    goose
    postgresql
    pgcli # PostgreSQL CLI with auto-completion and syntax highlighting

    prettier
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
    htmlhint
    stylelint
    yamllint
    markdownlint-cli
    statix
  ];
}
