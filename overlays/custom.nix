self: super:

{
  # example of a override
  # gopass = super.gopass.override { passAlias = true; };

  # this get the release 0.19.2 (same as the pkgs.freecad)
  # however getting freecad from pkgs is faster as the packages are prebuilt
  freecadLatest = super.freecad.overrideAttrs(oldAttrs: rec {
    name = "freecad";
    version = "0.19.2";
    src = super.fetchFromGitHub {
      owner = "FreeCAD";
      repo = "FreeCAD";
      rev = version;
      hash = "sha256-XZ+fRl3CPCIFu3nHeMTLibwwFBlG/cWpKJlI58hTAuU=";
    };
  });

  # freecad from a specific git commit id
  # Ex: override someVar and still get a specific version
  # freecadUnstable = (super.freecad.override { someVar = true; }).overrideAttrs(oldAttrs: rec {
  freecadUnstable = super.freecad.overrideAttrs(oldAttrs: rec {
    name = "freecadUnstable";
    version = "582c26ea8b5f9d85957a6cb1bf798839fa2ce94c";
    src = super.fetchFromGitHub {
      owner = "FreeCAD";
      repo = "FreeCAD";
      rev = version;
      # XXX: wrong sha256. How to find the correct from sha of the commit(version)?
      sha256 = "XZ+fRl3CPCIFu3nHeMTLibwwFBlG/cWpKJlI58hTAuU=";
    };
  });

}
