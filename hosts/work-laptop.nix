# 2021 MacBook Pro M1 Pro 16"
{root, ...}: {
  imports = [
    (root + /packages/darwin/default.nix)
  ];
}
