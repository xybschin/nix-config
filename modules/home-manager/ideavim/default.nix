{
  config,
  configRoot,
  ...
}:
{
  # Symlink .ideavimrc so edits to the file in the repo are reflected immediately.
  home.file.".ideavimrc".source =
    config.lib.file.mkOutOfStoreSymlink
      "${configRoot}/modules/home-manager/ideavim/.ideavimrc";
}
