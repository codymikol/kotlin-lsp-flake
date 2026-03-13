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
          url = "https://download-cdn.jetbrains.com/kotlin-lsp/262.1817.0/kotlin-lsp-262.1817.0-mac-x64.zip";
          sha256 = "dcae4b600483b7254417bcf1bf6cf3964f72d7194019e8c3126b75a2db2c115e";
        };

        aarch64-darwin = {
          url = "https://download-cdn.jetbrains.com/kotlin-lsp/262.1817.0/kotlin-lsp-262.1817.0-mac-aarch64.zip";
          sha256 = "46e34c7bd7cf6b6559656c684ad56e4a506ebccaa1f45d976f587bb84ef2ce4a";
        };

        x86_64-linux = {
          url = "https://download-cdn.jetbrains.com/kotlin-lsp/262.1817.0/kotlin-lsp-262.1817.0-linux-x64.zip";
          sha256 = "da6fca67b2f4056ccb65849c885f3d2752f992116e8ad8132dc028acc4845547";
        };

        aarch64-linux = {
          url = "https://download-cdn.jetbrains.com/kotlin-lsp/262.1817.0/kotlin-lsp-262.1817.0-linux-aarch64.zip";
          sha256 = "72c976d60e58ebd84f96310c27e6e6b7b5c6811c03f4f9633e9d7bae3c965705";
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
