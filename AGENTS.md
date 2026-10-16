# My day, a Runwell plugin — guide for AI agents

This repository is a plugin for Runwell (a Rails 8.1 engine loaded into a Runwell install). It is
not an app on its own: run it from a Runwell checkout with `bin/rails "plugins:link[path]"`.

Read first, in Runwell's repository:
- `docs/plugin-contract.md`: everything a plugin may rely on, with versions. Use nothing else of
  the core's. Raise `requires:` in the manifest to the newest version you use.
- `AGENTS.md`: the core's conventions, which plugin code follows too.

## Rules

- Own your tables, prefixed with the key (`my_day_*`), pointing at core records by id.
  Never add columns to core tables or write core rows except through core model verbs.
- Register everything in `config.to_prepare`, keyed by the plugin's key. Controllers inherit
  `MyDay::ApplicationController` (404 while switched off).
- Every controller action declares an authorization rule (`allow_staff`, `require_permission`)
  and an `agent_tool` or `agent_exempt`. Reads get a `.json.jbuilder` view with `agent_ref` and a
  `summary`. Write notices an AI can act on.
- Views follow the core's ReActionView rules: strict locals on every partial's first line,
  `<%# herb:key %>` before each loop row, no inline CSS, no partials inside `form_with`. Use the
  core's helpers and shared partials (listed in the contract) and `term()` for the core's nouns.
- CSS uses Runwell's design tokens (`docs/theming.md`), in `@layer components`.
- Migrations are safe on a live install: add in one release, remove only in a later one.
- Use only gems Runwell bundles: plugins load outside Bundler.
- The core's request and job N+1 detection (Prosopite) runs in tests: no query per item in a loop.

## Layout

- `lib/my_day/engine.rb`: routes, registrations
- `app/`: models, controllers, views, stylesheet under `my_day/`
- `db/migrate/`: the plugin's tables
- `test/test_helper.rb`: runs a test from a Runwell checkout (`bin/rails test path/to/this/test`)

## This plugin

- `MyDay::Day` is the page's query: the person's work (`Todo.assigned_to`, through
  `Current.user.person`, so an agent's day is its person's), filtered (`SHOWS`) and searched
  (title, engagement, client), in groups by due date, plus their priorities and every prioritised
  todo looked up once (`pinned_todos`, `{ id => todo }`).
- Priorities are a `Bundle` (one per person, `Bundle.priorities_for`, made when first needed) of
  `Pin`s (`todo_id`, `position`): `place(todo, before:)` adds or moves, `move(todo, :up / :down)`,
  `unpin`. A todo gone from the core is skipped (`todos_from`), never an error.
- Status changes go through the core's verb (`todo.update(status:)`), so the todo's history
  records them as anywhere else.
- The page is one page, reloaded in place: links and forms land back on `/my-day` with the same
  filter, search and todo, which Turbo morphs with the scroll kept (the core's
  `turbo_refreshes_with`). Not a turbo frame: Lexxy's editor (the notes) doesn't come back to
  life in content a frame swaps in. The search box is `data-turbo-permanent`; the notes section is
  rendered `permanent: false`, since its composer changes with the todo.
- Dragging is the core's `drag-and-drop` controller (the contract): the priorities are a sortable
  container posting to `priorities#create` (with `before`), the list a container posting to
  `priorities/:todo_id/removal`. Their answer is a turbo stream refresh without a request id (so
  Turbo doesn't skip it as its own echo); a session flag keeps the priorities unfolded after a
  change.
