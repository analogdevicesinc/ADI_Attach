fvm flutter clean
rm ios/output/Runner.ipa
fvm flutter pub get
fvm flutter build ios --release
cd ios
fastlane build
fastlane upload
cd ..