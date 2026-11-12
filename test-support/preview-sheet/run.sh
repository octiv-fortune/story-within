#!/bin/bash
# Test-only rendered UI regression. Never accepts a physical device destination.
set -euo pipefail
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 BOOTED_SIMULATOR_UDID" >&2
  exit 2
fi
simulator_id="$1"
repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
support_dir="$repo_root/test-support/preview-sheet"
harness_dir="$(mktemp -d /private/tmp/story-within-preview-ui.XXXXXX)"
export PREVIEW_REPO_ROOT="$repo_root" PREVIEW_HARNESS_DIR="$harness_dir"
python3 - "$simulator_id" <<'PY'
import json, subprocess, sys
inventory = json.loads(subprocess.check_output(['xcrun', 'simctl', 'list', 'devices', '--json']))
matches = [d for devices in inventory['devices'].values() for d in devices if d['udid'] == sys.argv[1]]
if len(matches) != 1 or matches[0]['state'] != 'Booted':
    raise SystemExit('Choose an already booted simulator. This script does not boot, erase, or reset devices.')
PY
python3 - <<'PY'
import os, plistlib, subprocess
from pathlib import Path
repo = Path(os.environ['PREVIEW_REPO_ROOT'])
out = Path(os.environ['PREVIEW_HARNESS_DIR'])
project = out/'StoryWithin.xcodeproj'
(project/'xcshareddata/xcschemes').mkdir(parents=True)
# Parse OpenStep/XML/binary plist through Apple's parser. Mutate the throwaway
# project structurally so Xcode's harmless project reformatting cannot break it.
p = plistlib.loads(subprocess.check_output(['plutil', '-convert', 'xml1', '-o', '-', str(repo/'StoryWithin.xcodeproj/project.pbxproj')]))
objects = p['objects']
app_groups = [o for o in objects.values() if o.get('isa') == 'PBXFileSystemSynchronizedRootGroup' and o.get('path') == 'StoryWithin']
test_groups = [o for o in objects.values() if o.get('isa') == 'PBXFileSystemSynchronizedRootGroup' and o.get('path') == 'StoryWithinTests']
test_targets = [o for o in objects.values() if o.get('isa') == 'PBXNativeTarget' and o.get('name') == 'StoryWithinTests']
assert len(app_groups) == len(test_groups) == len(test_targets) == 1, 'Expected existing app and test groups/target'
app_groups[0]['path'] = str(repo/'StoryWithin')
test_groups[0]['path'] = str(repo/'test-support/preview-sheet/UITests')
target = test_targets[0]
assert target['productType'] == 'com.apple.product-type.bundle.unit-test'
target['productType'] = 'com.apple.product-type.bundle.ui-testing'
configs = objects[target['buildConfigurationList']]['buildConfigurations']
for config_id in configs:
    settings = objects[config_id]['buildSettings']
    assert 'TEST_HOST' in settings and 'BUNDLE_LOADER' in settings, 'Expected hosted workflow test target'
    settings.pop('TEST_HOST')
    settings.pop('BUNDLE_LOADER')
    settings['TEST_TARGET_NAME'] = 'StoryWithin'
(project/'project.pbxproj').write_bytes(plistlib.dumps(p))
(project/'xcshareddata/xcschemes/StoryWithin.xcscheme').write_text((repo/'StoryWithin.xcodeproj/xcshareddata/xcschemes/StoryWithin.xcscheme').read_text())

PY
build_dir="$harness_dir/DerivedData"
build_args=(-project "$harness_dir/StoryWithin.xcodeproj" -scheme StoryWithin -configuration Debug -destination "platform=iOS Simulator,id=$simulator_id" -derivedDataPath "$build_dir" CODE_SIGNING_ALLOWED=NO -parallel-testing-enabled NO)
echo "Building UI harness; artifacts: $harness_dir"
xcodebuild "${build_args[@]}" build-for-testing > "$harness_dir/build.log" 2>&1
app_path="$build_dir/Build/Products/Debug-iphonesimulator/StoryWithin.app"
bundle_id="com.fortunemasekopersonalteam.StoryWithin"
xcrun simctl install "$simulator_id" "$app_path"
app_data="$(xcrun simctl get_app_container "$simulator_id" "$bundle_id" data)"
simulator_sdk="$(xcrun --sdk iphonesimulator --show-sdk-path)"
simulator_arch="$(uname -m)"
xcrun --sdk iphonesimulator swiftc -module-cache-path "$harness_dir/ModuleCache" -module-name StoryWithin -target "$simulator_arch-apple-ios27.0-simulator" -sdk "$simulator_sdk" -default-isolation MainActor -parse-as-library "$repo_root/StoryWithin/StoryWorkflow.swift" "$repo_root/StoryWithin/StoryCoaching.swift" "$repo_root/StoryWithin/OnDeviceStoryCoach.swift" "$repo_root/StoryWithin/AppleFoundationStoryModel.swift" "$repo_root/StoryWithin/DemoStory.swift" "$support_dir/Seed.swift" -o "$harness_dir/seed" > "$harness_dir/seed-build.log" 2>&1
xcrun simctl spawn "$simulator_id" "$harness_dir/seed" "$app_data" "$app_path/en-0004_goat.mp3" | tee "$harness_dir/seed.log"
xcodebuild "${build_args[@]}" -only-testing:StoryWithinTests/PreviewSheetTests/testFirstReviewTapRendersCommunityPreview -resultBundlePath "$harness_dir/PreviewSheet.xcresult" test-without-building > "$harness_dir/test.log" 2>&1 || {
  tail -35 "$harness_dir/test.log"
  exit 1
}
tail -15 "$harness_dir/test.log"
