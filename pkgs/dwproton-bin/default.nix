{ lib
, stdenvNoCC
, fetchzip
, writeShellApplication
, curl
, jq
, nix
, gnused
, steamInternalName ? "dwproton"
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dwproton-bin";
  version = "11.0-9";
  hash = "sha256-kWMYlF0H9iYjRcKmq/G4Ws4sTl+gN8nSFgfYvAOd754=";

  src = fetchzip {
    url = "https://dawn.wine/dawn-winery/dwproton/releases/download/dwproton-${finalAttrs.version}/dwproton-${finalAttrs.version}-x86_64.tar.xz";
    hash = finalAttrs.hash;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    echo "${finalAttrs.pname} should not be installed into environments. Please use programs.dwproton.enable instead." > $out

    mkdir $steamcompattool
    ln -s $src/* $steamcompattool

    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool
    chmod +w $steamcompattool/compatibilitytool.vdf
    sed -i \
      -e 's/"dwproton-[^"]*"/"${steamInternalName}"/' \
      -e '/"display_name"/ s/"[^"]*"[[:space:]]*$/"DW-Proton ${finalAttrs.version}"/' \
      $steamcompattool/compatibilitytool.vdf

    if ! grep -q '"${steamInternalName}"' $steamcompattool/compatibilitytool.vdf; then
      echo "error: failed to rewrite compatibilitytool.vdf to a stable key" >&2
      echo "       upstream's vdf format may have changed - check it by hand" >&2
      cat $steamcompattool/compatibilitytool.vdf >&2
      exit 1
    fi
    if grep -q 'dwproton-' $steamcompattool/compatibilitytool.vdf; then
      echo "error: versioned name still present in compatibilitytool.vdf" >&2
      cat $steamcompattool/compatibilitytool.vdf >&2
      exit 1
    fi

    runHook postInstall
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-dwproton";
    runtimeInputs = [ curl jq nix gnused ];
    text = ''
      set -euo pipefail

      GITEA_API="https://dawn.wine/api/v1"
      REPO="dawn-winery/dwproton"
      PKG_FILE="$(git rev-parse --show-toplevel)/pkgs/dwproton-bin/default.nix"

      TAG=$(curl -sf "$GITEA_API/repos/$REPO/releases?limit=1&page=1" \
        | jq -r 'map(select(.prerelease == false)) | .[0].tag_name')
      NEW_VERSION="''${TAG#dwproton-}"

      CURRENT_VERSION=$(nix eval --raw .#dwproton-bin.version)

      if [ "$NEW_VERSION" = "$CURRENT_VERSION" ]; then
        echo "dwproton is already up to date ($CURRENT_VERSION)"
        exit 0
      fi

      URL="https://dawn.wine/dawn-winery/dwproton/releases/download/$TAG/$TAG-x86_64.tar.xz"

      RAW=$(nix-prefetch-url --type sha256 --unpack "$URL")
      SRI=$(nix hash convert --hash-algo sha256 "$RAW")
      sed -i "s|^  version = \".*\";|  version = \"$NEW_VERSION\";|" "$PKG_FILE"
      sed -i "s|^  hash = \"sha256-.*\";|  hash = \"$SRI\";|" "$PKG_FILE"

      echo "dwproton $CURRENT_VERSION -> $NEW_VERSION ($SRI)"
    '';
  };

  meta = {
    description = "dwproton, a Proton fork maintained by dawn-winery";
    homepage = "https://dawn.wine/dawn-winery/dwproton";
    platforms = [ "x86_64-linux" ];
    license = with lib.licenses; [ bsd3 lgpl21Only mit zlib mpl20 ofl ];
  };
})
