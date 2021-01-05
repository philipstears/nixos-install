# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, ... }:

{
  home.file.".config/erlang_ls/erlang_ls.config".source = ./files/erlang-ls-config.yaml;
}

