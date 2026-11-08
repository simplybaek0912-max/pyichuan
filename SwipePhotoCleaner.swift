name: Build iOS IPA
on:
  push:
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Generate Xcode Project & Build IPA
        run: |
          SWIFT_FILE=$(find . -name "*.swift" | head -n 1)
          mkdir -p Sources
          cp "$SWIFT_FILE" Sources/SwipePhotoCleaner.swift
          cat << 'EOF' > Info.plist
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
              <key>CFBundleDevelopmentRegion</key><string>zh_CN</string>
              <key>CFBundleDisplayName</key><string>一划清</string>
              <key>CFBundleExecutable</key><string>$(EXECUTABLE_NAME)</string>
              <key>CFBundleIdentifier</key><string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
              <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
              <key>CFBundleName</key><string>$(PRODUCT_NAME)</string>
              <key>CFBundlePackageType</key><string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
              <key>CFBundleShortVersionString</key><string>1.0.0</string>
              <key>CFBundleVersion</key><string>1</string>
              <key>LSRequiresIPhoneOS</key><true/>
              <key>NSPhotoLibraryUsageDescription</key><string>需要访问您的相册，以便帮您浏览、收藏和清理照片。</string>
              <key>NSPhotoLibraryAddUsageDescription</key><string>需要访问您的相册，以便帮您整理照片。</string>
              <key>UILaunchScreen</key><dict/>
              <key>UIRequiredDeviceCapabilities</key><array><string>arm64</string></array>
              <key>UISupportedInterfaceOrientations</key><array><string>UIInterfaceOrientationPortrait</string></array>
          </dict>
          </plist>
          EOF
          cat << 'EOF' > project.yml
          name: SwipePhotoCleaner
          options:
            bundleIdPrefix: com.selfuse
            deploymentTarget: { iOS: "16.0" }
          targets:
            SwipePhotoCleaner:
              type: application
              platform: iOS
              deploymentTarget: "16.0"
              sources: [Sources]
              info: { path: Info.plist }
              settings:
                base:
                  PRODUCT_BUNDLE_IDENTIFIER: com.selfuse.swipephotocleaner
                  MARKETING_VERSION: 1.0.0
                  CURRENT_PROJECT_VERSION: 1
                  SWIFT_VERSION: "5.0"
                  TARGETED_DEVICE_FAMILY: "1"
                  CODE_SIGN_IDENTITY: ""
                  CODE_SIGNING_REQUIRED: "NO"
                  CODE_SIGNING_ALLOWED: "NO"
          EOF
          which xcodegen || brew install xcodegen
          xcodegen generate
          xcodebuild clean build -project SwipePhotoCleaner.xcodeproj -scheme SwipePhotoCleaner -sdk iphoneos -configuration Release -derivedDataPath build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
          mkdir -p Payload
          cp -r build/Build/Products/Release-iphoneos/SwipePhotoCleaner.app Payload/
          zip -r SwipePhotoCleaner.ipa Payload
      - uses: actions/upload-artifact@v4
        with:
          name: SwipePhotoCleaner-IPA
          path: SwipePhotoCleaner.ipa
