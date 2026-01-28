#!/bin/bash

# 从 pubspec.yaml 提取版本号
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | tr -d ' ')
# 提取主版本号（点号前的部分）
VERSION_SHORT=$(echo $VERSION | cut -d'+' -f1)

# 更新 README.md 中的版本号
sed -i '' "s/最新版本：v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/最新版本：v${VERSION_SHORT}/g" README.md

# 构建 APK
flutter build apk

# 复制到桌面
cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/one-v${VERSION_SHORT}.apk
