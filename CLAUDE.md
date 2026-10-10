# CLIuno Flutter template

Flutter (Material 3) client implementing the CLIuno demo app (auth, todos,
posts+comments, users, follows) against the shared CLIuno REST contract.
Targets android, ios and web.

## Commands

```bash
flutter pub get
flutter run --dart-define=API_BASE=http://localhost:3000/api/v1
flutter analyze          # must stay at "No issues found!"
flutter test             # widget smoke test
flutter build web        # or apk / ios
```

`API_BASE` defaults to `http://localhost:3000/api/v1`; Android emulators need
`http://10.0.2.2:<port>/api/v1`.

## Structure

- `lib/apis/` — the API layer (`auth_api`, `user_api`, `todo_api`, `post_api`,
  `follow_api`) on one Dio instance (`http.dart`): Bearer token from
  `shared_preferences`, 401 clears the stored session. **Keep every URL here** —
  the compatibility matrix parses `lib/apis/*.dart`, and paths deliberately use
  `'${id}'` brace interpolation so the matrix can map them to `:p` params
  (`unnecessary_brace_in_string_interps` is disabled for that reason).
- `lib/stores/auth_store.dart` — singleton `ChangeNotifier` (login/register/
  logout/hydrate); token storage is the Flutter analog of the web templates'
  localStorage.
- `lib/screens/` — login, register, forgot-password, todos (+detail),
  posts (+detail with comments), users (+detail with follow), profile;
  `lib/widgets/app_drawer.dart` is the shared navigation.

## The API contract (what backends guarantee)

Login sends `{usernameOrEmail, password}` and reads `data.token`. Responses are
`{status, message, data}` with exact keys `data.users/user/todos/todo/posts/post/`
`followers/following/isFollowing`; register sends snake_case fields. SQLite-backed
templates serialize booleans as 0/1 — compare with `== true || == 1`.

## Conventions

`flutter_lints` + `prefer_single_quotes`; conventional commits; no generated
platform files should be hand-edited except for permissions/app-id changes.

## AI agents (Claude Code and friends)

- **Check the CLIuno skills first**: `npx cliuno@latest skills status` — if any is
  `missing`/`outdated`, run `npx cliuno@latest skills install` (adds `.claude/skills/cliuno-*`:
  the generator workflow, the scaffold guide, and the shared REST contract).
- **Generate resources, don't hand-write them**:
  `npx cliuno@latest make:resource Product --fields name:string,price:number,inStock:boolean`
  creates `lib/apis/product_api.dart`, `lib/screens/products_screen.dart`, `lib/screens/product_detail_screen.dart` and registers it in `lib/main.dart`, following this
  template's conventions and the `{status, message, data}` contract. `--dry-run` previews,
  re-running never duplicates registrations, `--force` overwrites.
- Single pieces: `make:api`, `make:page`, `make:store`, `make:component`. `npx cliuno@latest make` lists them.
- Then edit fields/business logic only, and run the gates above.
