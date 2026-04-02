# iOS Build Rehberi - E Sport Life

Bu rehber, uygulamayı iOS için build etmek ve App Store'a yüklemek için gerekli tüm adımları içerir.

## 📋 Ön Gereksinimler

1. **macOS** (Mac bilgisayar gerekli)
2. **Xcode** yüklü olmalı (App Store'dan indirin)
3. **Flutter SDK** yüklü olmalı
4. **CocoaPods** yüklü olmalı (`sudo gem install cocoapods`)
5. **Apple Developer Hesabı** (App Store'a yüklemek için)

## 🔧 Build Adımları

### Yöntem 1: Otomatik Script (Önerilen)

```bash
cd ios_build
./build_ios.sh
```

Script size adım adım rehberlik edecektir. Script otomatik olarak proje root dizinine geçecektir.

### Yöntem 2: Manuel Adımlar

#### 1. Flutter Dependencies Yükleme

```bash
flutter pub get
```

#### 2. iOS Pods Yükleme

```bash
cd ios
pod install
cd ..
```

#### 3. Build Komutu

**Debug build için:**
```bash
flutter build ios --debug
```

**Profile build için:**
```bash
flutter build ios --profile
```

**Release build için (App Store):**
```bash
flutter build ios --release
```

## 📱 Xcode ile Build ve Archive

### 1. Xcode'u Açın

```bash
open ios/Runner.xcworkspace
```

**ÖNEMLİ:** `.xcworkspace` dosyasını açın, `.xcodeproj` değil!

### 2. Xcode Ayarları

#### Signing & Capabilities Kontrolü

1. Sol panelden **Runner** projesini seçin
2. **Signing & Capabilities** sekmesine gidin
3. **Team** seçin (Apple Developer hesabınız)
4. **Bundle Identifier** kontrol edin: `com.manasteknoloji.esport`
5. **Automatically manage signing** işaretli olmalı

#### Build Ayarları

1. Üst kısımdan **Any iOS Device** veya gerçek cihaz seçin
2. **Product > Scheme > Runner** seçili olmalı

### 3. Archive Oluşturma

1. **Product > Archive** seçin
2. Build tamamlandığında **Organizer** penceresi açılacak
3. Archive'ı seçin ve **Distribute App** butonuna tıklayın

### 4. App Store'a Yükleme

1. **App Store Connect** seçin
2. **Upload** seçin
3. Gerekli seçenekleri onaylayın
4. **Upload** butonuna tıklayın

## ⚙️ Önemli Ayarlar

### Version ve Build Number

`pubspec.yaml` dosyasında:
```yaml
version: 4.0.0+108
```
- `4.0.0` = Version (CFBundleShortVersionString)
- `108` = Build Number (CFBundleVersion)

Her yeni build için build number'ı artırın!

### Info.plist Ayarları

`ios/Runner/Info.plist` dosyasında kontrol edilmesi gerekenler:
- ✅ CFBundleDisplayName: "E Sport Life"
- ✅ UISupportedInterfaceOrientations (iPad desteği var)
- ✅ NSContactsUsageDescription (Rehber izni açıklaması)

### Minimum iOS Version

- **iOS 13.0** (project.pbxproj'de ayarlı)

## 🐛 Yaygın Sorunlar ve Çözümleri

### 1. Pod Install Hatası

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### 2. Signing Hatası

- Xcode'da **Signing & Capabilities** bölümünden Team seçin
- Apple Developer hesabınızın geçerli olduğundan emin olun

### 3. Build Hatası

```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ios --release
```

### 4. Archive Hatası

- Xcode'da **Product > Clean Build Folder** (Shift+Cmd+K)
- Sonra tekrar **Product > Archive**

## 📦 App Store Connect Hazırlığı

1. **App Store Connect**'e giriş yapın
2. Uygulamanızı seçin veya yeni uygulama oluşturun
3. Gerekli bilgileri doldurun:
   - Screenshot'lar (iPad için de gerekli!)
   - Açıklama
   - Kategori
   - Privacy Policy URL
   - vb.

## ✅ Build Öncesi Kontrol Listesi

- [ ] `pubspec.yaml`'da version ve build number güncel
- [ ] Tüm testler geçiyor
- [ ] iPad'de test edildi (özellikle login ekranı scroll sorunu düzeltildi)
- [ ] Info.plist'te gerekli izin açıklamaları var
- [ ] Xcode'da signing ayarları doğru
- [ ] Flutter dependencies güncel (`flutter pub get`)
- [ ] iOS Pods güncel (`pod install`)

## 🚀 Hızlı Komutlar

```bash
# Script ile build (ios_build klasöründen)
cd ios_build
./build_ios.sh

# Tüm adımları tek seferde (proje root'undan)
flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter build ios --release

# Xcode'u aç
open ios/Runner.xcworkspace
```

## 📞 Yardım

Sorun yaşarsanız:
1. Flutter dokümantasyonunu kontrol edin
2. Xcode console loglarını inceleyin
3. `flutter doctor` komutu ile Flutter kurulumunu kontrol edin
