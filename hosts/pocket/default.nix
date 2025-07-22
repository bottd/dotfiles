{ ...
}: {
  imports = [
    ./configuration.nix
    ./optimizations.nix
    ../../system/base
    ../../system/common/linux
    ../../system/users
  ];
}
