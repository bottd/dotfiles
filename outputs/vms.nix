{ self, inputs, lib, ... }: {
  # Wrap each Linux nixosConfiguration as a runnable QEMU VM. `nix run .#vm-<host>` boots.
  perSystem = { system, ... }:
    let
      isLinux = lib.hasSuffix "linux" system;

      # quote: mount the launcher's working set at the same paths it uses on metal,
      # so live edits in ~/workspace flow through to the guest.
      sharesFor = name:
        if name == "quote" then {
          quote-mc = {
            source = "/home/drakeb/workspace/quote-mc";
            target = "/home/drakeb/workspace/quote-mc";
            securityModel = "passthrough";
          };
          director = {
            source = "/home/drakeb/workspace/director";
            target = "/home/drakeb/workspace/director";
            securityModel = "passthrough";
          };
          quote-pack = {
            source = "/home/drakeb/workspace/3rd-brain";
            target = "/home/drakeb/workspace/3rd-brain";
            securityModel = "passthrough";
          };
        } else { };

      mkVm = name: cfg:
        (cfg.extendModules {
          modules = [
            "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
            (_: {
              virtualisation = {
                memorySize = 4096;
                cores = 4;
                diskSize = 8192;
                graphics = true;
                qemu.options = [
                  # qxl gives more reliable early-KMS for Plymouth than virtio under qemu-vm
                  "-vga qxl"
                  "-qmp unix:/tmp/qmp-${name}.sock,server,nowait"
                  "-serial file:/tmp/${name}-serial.log"
                ];
                sharedDirectories = sharesFor name;
              };
            })
          ];
        }).config.system.build.vm;

      vms = lib.mapAttrs mkVm
        (lib.filterAttrs
          (_: cfg: cfg.config.nixpkgs.hostPlatform.system == system)
          self.nixosConfigurations);

      vmApps = lib.mapAttrs'
        (name: vm: lib.nameValuePair "vm-${name}" {
          type = "app";
          program = "${vm}/bin/run-${name}-vm";
          meta.description = "Boot the ${name} NixOS host as a QEMU VM.";
        })
        vms;

      vmPackages = lib.mapAttrs' (name: lib.nameValuePair "vm-${name}") vms;
    in
    lib.optionalAttrs isLinux {
      apps = vmApps;
      packages = vmPackages;
    };
}
