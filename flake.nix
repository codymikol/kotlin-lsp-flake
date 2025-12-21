{

  description = "kotlin-lsp;";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
  
      pkgs = nixpkgs.legacyPackages.${system};

      sources = {
        x86_64-darwin = {
          url = "https://download-cdn.jetbrains.com/kotlin-lsp/261.13587.0/kotlin-lsp-261.13587.0-mac-x64.zip";
          sha256 = "a3972f27229eba2c226060e54baea1c958c82c326dfc971bf53f72a74d0564a3";
        };

        aarch64-darwin = {
          url = "https://download-cdn.jetbrains.com/kotlin-lsp/261.13587.0/kotlin-lsp-261.13587.0-mac-aarch64.zip";
          sha256 = "d4ea28b22b29cf906fe16d23698a8468f11646a6a66dcb15584f306aaefbee6c";
        };

        x86_64-linux = {
          url = "https://download-cdn.jetbrains.com/kotlin-lsp/261.13587.0/kotlin-lsp-261.13587.0-linux-x64.zip";
          sha256 = "dc0ed2e70cb0d61fdabb26aefce8299b7a75c0dcfffb9413715e92caec6e83ec";
        };

        aarch64-linux = {
          url = "https://download-cdn.jetbrains.com/kotlin-lsp/261.13587.0/kotlin-lsp-261.13587.0-linux-aarch64.zip";
          sha256 = "d1dceb000fe06c5e2c30b95e7f4ab01d05101bd03ed448167feeb544a9f1d651";
        };

      };

      source = sources.${system}
        or (throw "Unsupported system: ${system}");

    in {
      packages.default = pkgs.stdenv.mkDerivation (finalAttrs: {
        name = "kotlin-lsp";

        src = pkgs.fetchurl {
          inherit (source) url sha256;
        };

        unpackPhase = "true";
        buildPhase = "true";

        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.unzip
          pkgs.temurin-bin
        ];

        propagatedBuildInputs = [pkgs.temurin-bin];

        installPhase = ''

          echo "creating $out/bin/kotlin-lsp"

          mkdir -p $out/libexec/kotlin-lsp
          mkdir -p $out/bin

          echo "unpacking kotlin-lsp to $out/libexec/kotlin-lsp"

          unzip $src -d $out/libexec/kotlin-lsp

          echo "creating wrapper script at $out/bin/kotlin-lsp"

          DIR=$out/libexec/kotlin-lsp

          cat > $out/libexec/kotlin-lsp/run <<EOF
          #!/usr/bin/env bash

          echo "starting kotlin-lsp from $DIR"

          exec java \
              --add-opens java.base/java.io=ALL-UNNAMED \
              --add-opens java.base/java.lang=ALL-UNNAMED \
              --add-opens java.base/java.lang.ref=ALL-UNNAMED \
              --add-opens java.base/java.lang.reflect=ALL-UNNAMED \
              --add-opens java.base/java.net=ALL-UNNAMED \
              --add-opens java.base/java.nio=ALL-UNNAMED \
              --add-opens java.base/java.nio.charset=ALL-UNNAMED \
              --add-opens java.base/java.text=ALL-UNNAMED \
              --add-opens java.base/java.time=ALL-UNNAMED \
              --add-opens java.base/java.util=ALL-UNNAMED \
              --add-opens java.base/java.util.concurrent=ALL-UNNAMED \
              --add-opens java.base/java.util.concurrent.atomic=ALL-UNNAMED \
              --add-opens java.base/java.util.concurrent.locks=ALL-UNNAMED \
              --add-opens java.base/jdk.internal.vm=ALL-UNNAMED \
              --add-opens java.base/sun.net.dns=ALL-UNNAMED \
              --add-opens java.base/sun.nio.ch=ALL-UNNAMED \
              --add-opens java.base/sun.nio.fs=ALL-UNNAMED \
              --add-opens java.base/sun.security.ssl=ALL-UNNAMED \
              --add-opens java.base/sun.security.util=ALL-UNNAMED \
              --add-opens java.desktop/com.apple.eawt=ALL-UNNAMED \
              --add-opens java.desktop/com.apple.eawt.event=ALL-UNNAMED \
              --add-opens java.desktop/com.apple.laf=ALL-UNNAMED \
              --add-opens java.desktop/com.sun.java.swing=ALL-UNNAMED \
              --add-opens java.desktop/com.sun.java.swing.plaf.gtk=ALL-UNNAMED \
              --add-opens java.desktop/java.awt=ALL-UNNAMED \
              --add-opens java.desktop/java.awt.dnd.peer=ALL-UNNAMED \
              --add-opens java.desktop/java.awt.event=ALL-UNNAMED \
              --add-opens java.desktop/java.awt.font=ALL-UNNAMED \
              --add-opens java.desktop/java.awt.image=ALL-UNNAMED \
              --add-opens java.desktop/java.awt.peer=ALL-UNNAMED \
              --add-opens java.desktop/javax.swing=ALL-UNNAMED \
              --add-opens java.desktop/javax.swing.plaf.basic=ALL-UNNAMED \
              --add-opens java.desktop/javax.swing.text=ALL-UNNAMED \
              --add-opens java.desktop/javax.swing.text.html=ALL-UNNAMED \
              --add-opens java.desktop/sun.awt=ALL-UNNAMED \
              --add-opens java.desktop/sun.awt.X11=ALL-UNNAMED \
              --add-opens java.desktop/sun.awt.datatransfer=ALL-UNNAMED \
              --add-opens java.desktop/sun.awt.image=ALL-UNNAMED \
              --add-opens java.desktop/sun.awt.windows=ALL-UNNAMED \
              --add-opens java.desktop/sun.font=ALL-UNNAMED \
              --add-opens java.desktop/sun.java2d=ALL-UNNAMED \
              --add-opens java.desktop/sun.lwawt=ALL-UNNAMED \
              --add-opens java.desktop/sun.lwawt.macosx=ALL-UNNAMED \
              --add-opens java.desktop/sun.swing=ALL-UNNAMED \
              --add-opens java.management/sun.management=ALL-UNNAMED \
              --add-opens jdk.attach/sun.tools.attach=ALL-UNNAMED \
              --add-opens jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED \
              --add-opens jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED \
              --add-opens jdk.jdi/com.sun.tools.jdi=ALL-UNNAMED \
              --enable-native-access=ALL-UNNAMED \
              -Djdk.lang.Process.launchMechanism=FORK \
              -Djava.awt.headless=true \
              -cp "$DIR/lib/*" com.jetbrains.ls.kotlinLsp.KotlinLspServerKt "\$@"

          EOF

          echo "setting executable permission on $out/libexec/kotlin-lsp/run"

          chmod +x $out/libexec/kotlin-lsp/run
        '';

        postFixup = ''

          echo "wrapping $out/bin/kotlin-lsp to set PATH"

          makeWrapper "$out/libexec/kotlin-lsp/run" "$out/bin/kotlin-lsp" \
            --prefix PATH ":" "${pkgs.temurin-bin}/bin"
        '';
      });
    });
}
