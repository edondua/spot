#!/usr/bin/env python3
"""
Generate a complete Xcode project for Spotted app
"""

import os
import uuid

def gen_uuid():
    """Generate a 24-character hex UUID for Xcode"""
    return uuid.uuid4().hex[:24].upper()

# Project paths
PROJECT_DIR = "/Users/doruntinaramadani/Desktop/Spotted"
PROJECT_NAME = "Spotted"
SOURCE_DIR = f"{PROJECT_DIR}/Spotted"

# Generate UUIDs for all components
PRODUCT_REF = gen_uuid()
PROJECT_REF = gen_uuid()
MAIN_GROUP = gen_uuid()
PRODUCTS_GROUP = gen_uuid()
TARGET_REF = gen_uuid()
BUILD_CONFIG_LIST_PROJECT = gen_uuid()
BUILD_CONFIG_LIST_TARGET = gen_uuid()
DEBUG_CONFIG_PROJECT = gen_uuid()
RELEASE_CONFIG_PROJECT = gen_uuid()
DEBUG_CONFIG_TARGET = gen_uuid()
RELEASE_CONFIG_TARGET = gen_uuid()
SOURCES_BUILD_PHASE = gen_uuid()
FRAMEWORKS_BUILD_PHASE = gen_uuid()
RESOURCES_BUILD_PHASE = gen_uuid()

# Collect Swift files
swift_files = []
for root, dirs, files in os.walk(SOURCE_DIR):
    for file in files:
        if file.endswith('.swift'):
            full_path = os.path.join(root, file)
            rel_path = os.path.relpath(full_path, SOURCE_DIR)
            swift_files.append({
                'name': file,
                'path': rel_path,
                'uuid': gen_uuid(),
                'build_uuid': gen_uuid()
            })

print(f"Found {len(swift_files)} Swift files")

# Create directory structure
os.makedirs(f"{PROJECT_DIR}/{PROJECT_NAME}.xcodeproj", exist_ok=True)
os.makedirs(f"{PROJECT_DIR}/{PROJECT_NAME}.xcodeproj/project.xcworkspace", exist_ok=True)
os.makedirs(f"{PROJECT_DIR}/{PROJECT_NAME}.xcodeproj/project.xcworkspace/xcshareddata", exist_ok=True)
os.makedirs(f"{PROJECT_DIR}/{PROJECT_NAME}.xcodeproj/xcuserdata", exist_ok=True)

# Generate file references section
file_refs = "\n".join([
    f"\t\t{f['uuid']} /* {f['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{f['path']}\"; sourceTree = \"<group>\"; }};"
    for f in swift_files
])

# Generate build files section
build_files = "\n".join([
    f"\t\t{f['build_uuid']} /* {f['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {f['uuid']} /* {f['name']} */; }};"
    for f in swift_files
])

# Generate sources build phase files
sources_phase_files = "\n".join([
    f"\t\t\t\t{f['build_uuid']} /* {f['name']} in Sources */,"
    for f in swift_files
])

# Create the project.pbxproj file
pbxproj_content = f'''// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{build_files}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
\t\t{PRODUCT_REF} /* {PROJECT_NAME}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {PROJECT_NAME}.app; sourceTree = BUILT_PRODUCTS_DIR; }};
{file_refs}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{FRAMEWORKS_BUILD_PHASE} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{MAIN_GROUP} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{PRODUCTS_GROUP} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{PRODUCTS_GROUP} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{PRODUCT_REF} /* {PROJECT_NAME}.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{TARGET_REF} /* {PROJECT_NAME} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {BUILD_CONFIG_LIST_TARGET} /* Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */;
\t\t\tbuildPhases = (
\t\t\t\t{SOURCES_BUILD_PHASE} /* Sources */,
\t\t\t\t{FRAMEWORKS_BUILD_PHASE} /* Frameworks */,
\t\t\t\t{RESOURCES_BUILD_PHASE} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = {PROJECT_NAME};
\t\t\tproductName = {PROJECT_NAME};
\t\t\tproductReference = {PRODUCT_REF} /* {PROJECT_NAME}.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{PROJECT_REF} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1500;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{TARGET_REF} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {BUILD_CONFIG_LIST_PROJECT} /* Build configuration list for PBXProject "{PROJECT_NAME}" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {MAIN_GROUP};
\t\t\tproductRefGroup = {PRODUCTS_GROUP} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{TARGET_REF} /* {PROJECT_NAME} */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{RESOURCES_BUILD_PHASE} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{SOURCES_BUILD_PHASE} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{sources_phase_files}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t{DEBUG_CONFIG_PROJECT} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{RELEASE_CONFIG_PROJECT} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{DEBUG_CONFIG_TARGET} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.spotted.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{RELEASE_CONFIG_TARGET} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.spotted.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{BUILD_CONFIG_LIST_PROJECT} /* Build configuration list for PBXProject "{PROJECT_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{DEBUG_CONFIG_PROJECT} /* Debug */,
\t\t\t\t{RELEASE_CONFIG_PROJECT} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{BUILD_CONFIG_LIST_TARGET} /* Build configuration list for PBXNativeTarget "{PROJECT_NAME}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{DEBUG_CONFIG_TARGET} /* Debug */,
\t\t\t\t{RELEASE_CONFIG_TARGET} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {PROJECT_REF} /* Project object */;
}}
'''

# Write project.pbxproj
pbxproj_path = f"{PROJECT_DIR}/{PROJECT_NAME}.xcodeproj/project.pbxproj"
with open(pbxproj_path, 'w') as f:
    f.write(pbxproj_content)

print(f"\n✅ Created: {pbxproj_path}")

# Create workspace contents
workspace_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
'''

workspace_path = f"{PROJECT_DIR}/{PROJECT_NAME}.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
with open(workspace_path, 'w') as f:
    f.write(workspace_content)

print(f"✅ Created: {workspace_path}")

# Create workspace checks
checks_content = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>IDEDidComputeMac32BitWarning</key>
\t<true/>
</dict>
</plist>
'''

checks_path = f"{PROJECT_DIR}/{PROJECT_NAME}.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist"
with open(checks_path, 'w') as f:
    f.write(checks_content)

print(f"✅ Created: {checks_path}")

print(f"\n🎉 Xcode project created successfully!")
print(f"\n📂 Project location: {PROJECT_DIR}/{PROJECT_NAME}.xcodeproj")
print(f"\n▶️  To open: open {PROJECT_DIR}/{PROJECT_NAME}.xcodeproj")
