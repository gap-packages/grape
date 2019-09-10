LoadPackage( "grape" );

if IsBound(GAPInfo.SystemEnvironment.GRAPE_NAUTY) then
    if GAPInfo.SystemEnvironment.GRAPE_NAUTY = "true" then
        GRAPE_NAUTY := true;
    elif GAPInfo.SystemEnvironment.GRAPE_NAUTY = "false" then
        GRAPE_NAUTY := false;
    fi;
fi;

TestDirectory(DirectoriesPackageLibrary( "grape", "tst" ),
  rec(exitGAP     := true,
      testOptions := rec(compareFunction := "uptowhitespace") ) );

FORCE_QUIT_GAP(1); # if we ever get here, there was an error
