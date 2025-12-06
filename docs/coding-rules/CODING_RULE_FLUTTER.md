# CORDING RULE FLUTTER

Flutter のコーディングルール

### Dart

- Effective Dart に準ずること

### アーキテクチャ（MVVM + Repository）

- MVVM + Repository を採用すること
- Model は freezed を用いること
- View は ConsumerStatefulWidget、ConsumerWidget、StatelessWidget、StatefulWidget のいずれかを用いること
- ViewModel は Riverpod Generator を用いること
