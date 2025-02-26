# ThorVG static libary build for iOS (for SVG and Lottie render)

### Thorvg ios build step:

a. Build for iOS Devices (arm64):
meson setup build-ios/ios_arm64 --cross-file cross/ios_arm64.txt -Dloaders="svg, lottie" -Dextra="" -Dstatic=True -Ddefault_library=static  --buildtype release 

ninja -C build-ios/ios_arm64

b. Build for the iOS Simulator (x86_64):
meson setup build-ios/ios_x86_64 --reconfigure --cross-file cross/ios_x86_64.txt -Dloaders="svg, lottie" -Dextra="" -Dstatic=True -Ddefault_library=static --buildtype release    

ninja -C build-ios/ios_x86_64


c. Creating a Universal (Fat) Library
lipo -create ./build-ios/ios_arm64/src/libthorvg.a ./build-ios/ios_x86_64/src/libthorvg.a -output ./build-ios/libthorvg/libthorvg-universal.a

d. Copy the header from ./inc

e. Import either libthorvg.a or ibthorvg-universal.a to Xcode project
f. Add header search path and library search path in project build setting

