#############################################################################
##  
##  PackageInfo.g for the package `grape'                   Leonard Soicher
##  

SetPackageInfo( rec(

##  This is case sensitive, use your preferred spelling.
PackageName := "GRAPE",

##  See '?Extending: Version Numbers' in GAP help for an explanation
##  of valid version numbers.
Version := "4.9.2",

##  Release date of the current version in dd/mm/yyyy format.
Date := "11/10/2024",

##  Machine readable license information (as an SPDX identifier)
License := "Apache-2.0 AND GPL-2.0-or-later",

SourceRepository := rec(
    Type := "git",
    URL :=  "https://github.com/gap-packages/grape",
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := "https://gap-packages.github.io/grape",
README_URL      := Concatenation( ~.PackageWWWHome, "/README.md" ),
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/grape-", ~.Version ),

ArchiveFormats := ".tar.gz", 

Persons := [
  rec(
    LastName := "Soicher",
    FirstNames := "Leonard H.",
    IsAuthor := true,
    IsMaintainer := true,
    Email := "L.H.Soicher@qmul.ac.uk",
    WWWHome := "https://webspace.maths.qmul.ac.uk/l.h.soicher/",
    Place := "London, UK",
    Institution := Concatenation( [
      "School of Mathematical Sciences, ",
      "Queen Mary University of London",
      ] )
    )
],

Status := "accepted",

CommunicatedBy := "Leonard Soicher (QMUL)",
AcceptDate := "07/1993", 

##  Here you  must provide a short abstract explaining the package content 
##  in HTML format (used on the package overview Web page) and an URL 
##  for a Webpage with more detailed information about the package
##  (not more than a few lines, less is ok):
##  Please, use '<span class="pkgname">GAP</span>' and
##  '<span class="pkgname">MyPKG</span>' for specifying package names.
##  
AbstractHTML := "<span class=\"pkgname\">GRAPE</span> is a package for \
computing with graphs and groups, \
and is primarily designed for constructing and analysing graphs \
related to groups, finite geometries, and designs.",

PackageDoc := rec(
  # use same as in GAP            
  BookName := "GRAPE",
  ArchiveURLSubset := ["htm", "doc/manual.pdf"],
  HTMLStart := "htm/chapters.htm",
  PDFFile := "doc/manual.pdf",
  # the path to the .six file used by GAP's help system
  SixFile := "doc/manual.six",
  # a longer title of the book, this together with the book name should
  # fit on a single text line (appears with the '?books' command in GAP)
  LongTitle := "GRaph Algorithms using PErmutation groups",
  # Should this help book be autoloaded when GAP starts up? This should
  # usually be 'true', otherwise say 'false'. 
  Autoload := true
),


##  Are there restrictions on the operating system for this package? Or does
##  the package need other packages to be available?
Dependencies := rec(
  # GAP version, use version strings for specifying exact versions,
  # prepend a '>=' for specifying a least version.
  GAP := ">=4.11",
  # list of pairs [package name, (least) version],  package name is case
  # insensitive, least version denoted with '>=' prepended to version string.
  # without these, the package will not load
  # NeededOtherPackages := [["GAPDoc", ">= 0.99"]],
  NeededOtherPackages := [],
  # without these the package will issue a warning while loading
  # SuggestedOtherPackages := [],
  SuggestedOtherPackages := [],
  # needed external conditions (programs, operating system, ...)  provide 
  # just strings as text or
  # pairs [text, URL] where URL  provides further information
  # about that point.
  # (no automatic test will be done for this, do this in your 
  # 'AvailabilityTest' function below)
  # ExternalConditions := []
  ExternalConditions := []
                      
),

## Provide a test function for the availability of this package, see
## documentation of 'Declare(Auto)Package', this is the <tester> function.
## For packages which will not fully work, use 'Info(InfoWarning, 1,
## ".....")' statements. For packages containing nothing but GAP code,
## just say 'ReturnTrue' here.
## (When this is used for package loading in the future the availability
## tests of other packages, as given above, will be done automatically and
## need not be included here.)
AvailabilityTest := ReturnTrue,
# AvailabilityTest := 
# function()
#   if ExternalFilename(DirectoriesPackagePrograms("grape"),"dreadnautB") = fail
#     and ExternalFilename(DirectoriesPackagePrograms("grape"),"dreadnautB.exe") = fail then 
#     LogPackageLoadingMessage(PACKAGE_WARNING,["nauty/dreadnaut binary not installed,", "functions depending on nauty will not work"]);
#   fi;
#   return true;
# end,

Subtitle := "GRaph Algorithms using PErmutation groups",

##  *Optional*, but recommended: path relative to package root to a file which 
##  contains as many tests of the package functionality as sensible.
TestFile := "tst/testall.g",

##  *Optional*: Here you can list some keyword related to the topic 
##  of the package.
Keywords := ["graph","design","finite geometry","clique number","chromatic number"]

));


