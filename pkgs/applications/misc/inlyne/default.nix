{ lib
, rustPlatform
, fetchFromGitHub
, installShellFiles
, stdenv
, pkg-config
, fontconfig
, xorg
, libxkbcommon
, wayland
, libGL
, openssl
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "inlyne";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "trimental";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-kZQREYnauR8xusyX6enBPUKHSe39aBLlrZjKEjJlfx0=";
  };

  cargoHash = "sha256-2mQFr2nLJ/iBLpdOUmerY6F2C8Kt+/vMEjS6THpmJic=";

  nativeBuildInputs = [
    installShellFiles
  ] ++ lib.optionals stdenv.isLinux [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    fontconfig
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    xorg.libxcb
    wayland
    libxkbcommon
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk_11_0.frameworks.AppKit
  ];

  checkFlags = lib.optionals stdenv.isDarwin [
    # time out on darwin
    "--skip=interpreter::tests::centered_image_with_size_align_and_link"
    "--skip=watcher::tests::the_gauntlet"
  ];

  postInstall = ''
    installShellCompletion --cmd inlyne \
      --bash <($out/bin/inlyne --gen-completions bash) \
      --fish <($out/bin/inlyne --gen-completions fish) \
      --zsh <($out/bin/inlyne --gen-completions zsh)
  '';

  postFixup = lib.optionalString stdenv.isLinux ''
    patchelf $out/bin/inlyne \
      --add-rpath ${lib.makeLibraryPath [ libGL xorg.libX11 ]}
  '';

  meta = with lib; {
    description = "A GPU powered browserless markdown viewer";
    homepage = "https://github.com/trimental/inlyne";
    changelog = "https://github.com/trimental/inlyne/releases/tag/${src.rev}";
    license = licenses.mit;
    maintainers = with maintainers; [ figsoda ];
    mainProgram = "inlyne";
  };
}
