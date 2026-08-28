{ pkgs, ... }:
{
  imports = [
    ./claude
    ./opencode
    ./seo
  ];

  # One definition shared by the modules above; they take `seo` as an argument
  # rather than each calling into ./seo/package.nix.
  _module.args.seo = pkgs.callPackage ./seo/package.nix { };
}
