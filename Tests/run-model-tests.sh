#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
TEST_OUTPUT=$(mktemp -d /private/tmp/stor-model-tests.XXXXXX)
trap 'rm -rf "$TEST_OUTPUT"' EXIT
# Xcode normally generates these named Color accessors when building the app.
# The host model runner uses the same asset definitions, without a UI target.
python3 - "$TEST_OUTPUT/AssetColors.swift" <<'PY'
import json, pathlib, sys
lines = ['import SwiftUI', 'extension Color {']
for path in sorted(pathlib.Path('Stor/Assets.xcassets').glob('*.colorset/Contents.json')):
    data = json.loads(path.read_text())['colors'][0]['color']['components']
    components = [int(data[k][2:], 16) / 255 if data[k].startswith('0x') else float(data[k]) for k in ['red','green','blue']]
    lines.append(f'static let {path.parent.stem} = Color(red: {components[0]}, green: {components[1]}, blue: {components[2]})')
lines.append('}')
pathlib.Path(sys.argv[1]).write_text('\n'.join(lines))
PY
xcrun --sdk macosx swiftc -parse-as-library -target "$(uname -m)-apple-macosx14.0" \
    -module-cache-path "$TEST_OUTPUT/ModuleCache" \
    Stor/Models/*.swift Stor/Mock/*.swift Stor/AppState.swift Stor/DesignSystem/Formatters.swift \
    "$TEST_OUTPUT/AssetColors.swift" Tests/ModelRegressionTests.swift -o "$TEST_OUTPUT/model-tests"
"$TEST_OUTPUT/model-tests"
