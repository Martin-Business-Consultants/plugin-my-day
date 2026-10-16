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

- `MyDay::Day` is the page's query: the person's work (`Todo.assigned_to`, through `Current.user.person`,
  so an agent's day is its person's), filtered (`SHOWS`) and searched (title, engagement, client),
  in groups by due date, plus their `Bundle`s and every pinned todo looked up once
  (`pinned_todos`, `{ id => todo }`). `after` is what Done, and next opens: the next open one in
  the bundle the todo was opened from (`from_bundle`), else in the list.
- `Bundle` (a person's, `user_id`) has `Pin`s (`todo_id`, `position`): `pin` (at the bottom,
  once), `unpin`, `move(todo, :up / :down)`. A todo gone from the core is skipped
  (`todos_from`), never an error.
- Status changes go through the core's verb (`todo.update(status:)`), so the todo's history
  records them as anywhere else.
- The page is one turbo frame (`my_day`): picking, searching, filtering and every form reload only
  it and keep the filter, search and bundle (`my_day_return_params`). The search box is
  `data-turbo-permanent`, so typing keeps focus while the list reloads. Bundles unfold with a
  native `<details>`; no JavaScript of the plugin's own.
