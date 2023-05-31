# Install

- `yarn` 입력으로 RN 라이브러리 설치
- `cd ios`  ios 디렉토리로 이동
- `pod install` pod install. RCT-Folly 관련 에러가 나면 에러메세지의 pod update 문을 실행한다.
- RNPreBuild.xcworkspace 를 열어 빌드시 성공해야함.
- `sh build_xcframework.sh` 실행 하면 xcframework 들 빌드