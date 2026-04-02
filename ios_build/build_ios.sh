#!/bin/bash

# iOS Build Script for E Sport Life
# Bu script iOS build için gerekli adımları otomatik olarak yürütür
# Script ios_build klasöründen çalıştırılmalıdır

set -e  # Hata durumunda dur

# Proje root dizinine git
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "🚀 iOS Build başlatılıyor..."
echo "📁 Proje dizini: $PROJECT_ROOT"

# 1. Flutter clean (opsiyonel - temiz build için)
read -p "Flutter clean yapmak istiyor musunuz? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📦 Flutter clean yapılıyor..."
    flutter clean
fi

# 2. Flutter pub get
echo "📦 Flutter dependencies yükleniyor..."
flutter pub get

# 3. iOS Pods yükleme
echo "📦 iOS Pods yükleniyor..."
cd ios
pod install
cd ..

# 4. Build tipi seçimi
echo ""
echo "Build tipi seçiniz:"
echo "1) Debug"
echo "2) Profile"
echo "3) Release (App Store için)"
read -p "Seçiminiz (1/2/3): " build_type

case $build_type in
    1)
        BUILD_MODE="debug"
        ;;
    2)
        BUILD_MODE="profile"
        ;;
    3)
        BUILD_MODE="release"
        ;;
    *)
        echo "Geçersiz seçim. Release modu kullanılıyor."
        BUILD_MODE="release"
        ;;
esac

# 5. iOS Build
echo "🔨 iOS build başlatılıyor ($BUILD_MODE modu)..."
flutter build ios --$BUILD_MODE

echo ""
echo "✅ Build tamamlandı!"
echo ""
echo "📱 Sonraki adımlar:"
echo "1. Xcode'u açın: open ios/Runner.xcworkspace"
echo "2. Product > Archive seçin"
echo "3. Organizer'dan App Store'a yükleyin"
echo ""
echo "Veya doğrudan Xcode ile build yapmak için:"
echo "   open ios/Runner.xcworkspace"
