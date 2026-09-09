{ callPackage, symlinkJoin }:

symlinkJoin {
  name = "janet-modules";
  paths = [
    (callPackage ./spork.nix { })
    (callPackage ./cmd.nix { })
  ];
}
