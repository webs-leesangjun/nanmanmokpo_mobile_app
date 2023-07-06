# nangmanmokpo

### IOS APN 인증 키 파일

- ios/AuthKey_Q67KY7VGNS.p8

### 안드로이드 Apk 생성
```bash
flutter build apk --release --target-platform=android-arm64 
```

### IOS Testflight 업로드

- xcode 에서 Product 메뉴 > Archive 클릭 
- Distribute App 버튼 클릭 



- firebase_options 파일 생성
```bash
  flutterfire configure --project=mokpo --out=lib/firebase_options.dart --ios-bundle-id=im.ureca.nangmanmokpo --android-app-id=im.ureca.nangmanmokpo 
```


참고
https://github.com/firebase/flutterfire/blob/master/packages/firebase_messaging/firebase_messaging/example/lib/firebase_options.dart
https://www.youtube.com/watch?v=imaPNoiH3I4


