# Unit test module for configuration
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Import the module system
  moduleSystem = import ../utils/module-system.nix {inherit lib;};

  # Test cases for the module system
  testModuleSystem = {
    # Test creating a module
    testMkModule = let
      module = moduleSystem.mkModule {
        defaults = {
          a = 1;
          b = 2;
        };
        overrides = {
          b = 3;
          c = 4;
        };
      };
    in
      assert module.defaults.a == 1;
      assert module.defaults.b == 2;
      assert module.overrides.b == 3;
      assert module.overrides.c == 4;
      assert module.enable == true; true;

    # Test overriding a module
    testOverrideModule = let
      module = moduleSystem.mkModule {
        defaults = {
          a = 1;
          b = 2;
        };
      };
      overridden = moduleSystem.overrideModule module {
        b = 3;
        c = 4;
      };
    in
      assert overridden.defaults.a == 1;
      assert overridden.defaults.b == 2;
      assert overridden.overrides.b == 3;
      assert overridden.overrides.c == 4; true;

    # Test getting module config
    testGetModuleConfig = let
      module = moduleSystem.mkModule {
        defaults = {
          a = 1;
          b = 2;
        };
        overrides = {
          b = 3;
          c = 4;
        };
      };
      finalConfig = moduleSystem.getModuleConfig module;
    in
      assert finalConfig.a == 1;
      assert finalConfig.b == 3; # Overridden value
      
      assert finalConfig.c == 4; true;

    # Test disabling a module
    testDisabledModule = let
      module = moduleSystem.mkModule {
        defaults = {a = 1;};
        enable = false;
      };
      finalConfig = moduleSystem.getModuleConfig module;
    in
      assert finalConfig == {}; true;
  };

  # Test cases for the conditional module system
  testConditionalSystem = let
    conditional = import ../utils/conditional.nix {inherit lib;};
  in {
    # Test basic import condition
    testImport = let
      resultTrue = conditional.import true {a = 1;};
      resultFalse = conditional.import false {a = 1;};
    in
      assert resultTrue.a == 1;
      assert resultFalse == {}; true;

    # Test withFeature function
    testWithFeature = let
      resultTrue = conditional.withFeature true {a = 1;};
      resultFalse = conditional.withFeature false {a = 1;};
    in
      assert resultTrue.a == 1;
      assert resultFalse == {}; true;

    # Test onlyOn function
    testOnlyOn = let
      resultMatch = conditional.onlyOn "x86_64-linux" {a = 1;} "x86_64-linux";
      resultNoMatch = conditional.onlyOn "x86_64-linux" {a = 1;} "aarch64-darwin";
    in
      assert resultMatch.a == 1;
      assert resultNoMatch == {}; true;

    # Test merge function
    testMerge = let
      merged = conditional.merge [
        {
          a = 1;
          b = 2;
        }
        {}
        {
          b = 3;
          c = 4;
        }
      ];
    in
      assert merged.a == 1;
      assert merged.b == 3;
      assert merged.c == 4; true;
  };
in {
  # Run all tests and assert they pass
  assertions = [
    {
      assertion = testModuleSystem.testMkModule;
      message = "Test failed: testMkModule";
    }
    {
      assertion = testModuleSystem.testOverrideModule;
      message = "Test failed: testOverrideModule";
    }
    {
      assertion = testModuleSystem.testGetModuleConfig;
      message = "Test failed: testGetModuleConfig";
    }
    {
      assertion = testModuleSystem.testDisabledModule;
      message = "Test failed: testDisabledModule";
    }
    {
      assertion = testConditionalSystem.testImport;
      message = "Test failed: testImport";
    }
    {
      assertion = testConditionalSystem.testWithFeature;
      message = "Test failed: testWithFeature";
    }
    {
      assertion = testConditionalSystem.testOnlyOn;
      message = "Test failed: testOnlyOn";
    }
    {
      assertion = testConditionalSystem.testMerge;
      message = "Test failed: testMerge";
    }
  ];
}
