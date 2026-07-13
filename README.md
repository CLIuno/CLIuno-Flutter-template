# CLIuno Flutter template

Flutter client for the CLIuno demo app — auth, todos, posts + comments, users and
follows — talking to **any CLIuno backend template** over the shared REST contract.

## Quick start

```bash
flutter pub get
flutter run                # uses http://localhost:3000/api/v1
```

Point it at another backend or a device-reachable host:

```bash
flutter run --dart-define=API_BASE=http://10.0.2.2:3000/api/v1   # Android emulator
flutter run -d chrome --dart-define=API_BASE=http://localhost:8000/api/v1
```

## Layout

- `lib/apis/` — the API layer (`auth_api`, `user_api`, `todo_api`, `post_api`,
  `follow_api`) on a shared Dio instance in `http.dart`. Bearer token comes from
  `shared_preferences`; a 401 clears the stored session.
- `lib/stores/auth_store.dart` — app-wide auth state (`ChangeNotifier`).
- `lib/screens/` — Material screens: login, register, forgot-password, todos (+detail),
  posts (+detail with comments), users (+detail with follow), profile.

## The API contract

Login sends `{usernameOrEmail, password}` and reads `data.token`. Responses are
`{status, message, data}` with the exact keys `data.users/user/todos/todo/posts/post/`
`followers/following/isFollowing`. Keep all URLs inside `lib/apis/` — the CLIuno
compatibility matrix parses those files.

## Checks

```bash
flutter analyze
flutter test
```
