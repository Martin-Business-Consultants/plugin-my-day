# My day for Runwell

The work assigned to you in one list, and the piece you pick open beside it: a way to work through
the day.

A Runwell plugin (Runwell's `docs/plugins.md`): a Rails engine that owns its `my_day_*` tables,
points at people and work by id, and extends the core only through the plugin contract. Needs
Runwell 2.25.4 or newer.

## Install

Settings › Plugins › Install, with `Martin-Business-Consultants/plugin-my-day`, or from the shell:

    bin/rails "plugins:install[Martin-Business-Consultants/plugin-my-day]"

Then switch it on in Settings › Plugins.

## What it does

- **My day**, in the nav: two columns, half and half.
- **On the left, your work**: everything you lead or are on, grouped by when it's due (late,
  today, this week, later, no date; work in review or blocked sits in its own groups at the
  bottom), oldest first in each, each with its state, where it's from and when it's due (late ones
  in red). A search box above it (as you type: the title, its engagement or its client) and a
  filter: everything open, due today or late, due this week, done this week, or everything.
- **Vim keys and bulk actions**: `j` / `k` move through the list (`gg` and `G` to the first and
  last), Enter or `o` opens the one you're on, and `x` picks it (or tick its box). With any picked,
  a bar above the list adds them to your priorities or takes them off, and sets their status, due
  date or lead all at once (the core's bulk actions, so each todo's history records it).
- **Priorities, at the top**: a drop area that gathers the day's priorities, five at most, with
  its free places shown. Drag work onto it (in the order you'll do it, or drag within it to
  reorder), and drag it back onto the list to take it off. Click it to unfold its work, numbered,
  with how much is done; finished work turns green. Your priorities are yours alone.
- **On the right, the piece you picked**: a card with its engagement and client, and everything
  changed in place: its status (the badge is a dropdown), its due date (saved as you pick it), who's
  on it (the core's people picker: the first on leads), and its details (click them to edit, with
  @mentions). Then its place in your priorities (add, move up or down, remove: the same without
  dragging) and Open in Work; under it, its notes, with the composer to add one.

## Agents

`show_my_day` (with `show`, `q` and `todo`), `add_my_day_priority` (with `before`),
`move_my_day_priority`, `remove_my_day_priority`, `bulk_add_my_day_priorities`,
`bulk_remove_my_day_priorities`, `set_my_day_status` and `update_my_day_todo` (due date, details);
the core's `bulk_update_work` for status, lead and due date on several at once. "Working through
someone's day" is offered to agents as a workflow. An agent's priorities are its person's.

## Developing

Clone it beside a Runwell checkout, then from Runwell:

    bin/rails "plugins:link[../plugin-my-day]"
    bin/rails db:migrate
    bin/dev

`bin/rails agent:coverage`, `bundle exec herb lint ../plugin-my-day/app/views` and
`bin/rubocop ../plugin-my-day` should all be clean.

## Releasing

Bump `lib/my_day/version.rb`, commit, and push a matching `vX.Y.Z` tag: the release workflow
publishes it, and installs see it as an update in Settings › Plugins.
