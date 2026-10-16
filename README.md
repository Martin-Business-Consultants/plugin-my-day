# My day for Runwell

The work assigned to you in one list, and the piece you pick open beside it: a way to work through
the day.

A Runwell plugin (Runwell's `docs/plugins.md`): a Rails engine that owns its `my_day_*` tables,
points at people and work by id, and extends the core only through the plugin contract. Needs
Runwell 2.24 or newer (2.25 for its sun in the nav).

## Install

Settings › Plugins › Install, with `Martin-Business-Consultants/plugin-my-day`, or from the shell:

    bin/rails "plugins:install[Martin-Business-Consultants/plugin-my-day]"

Then switch it on in Settings › Plugins.

## What it does

- **My day**, in the nav: two columns, half and half.
- **On the left, your work**: everything you lead or are on, grouped by when it's due (late,
  today, this week, later, no date), each with its state, where it's from and when it's due (late
  ones in red). A search box above it (as you type: the title, its engagement or its client) and a
  filter: everything open, due today or late, due this week, done this week, or everything.
- **Bundles, pinned at the top**: named groups of work in the order you mean to do them ("Before
  lunch", "Acme launch"). Click a bundle and it unfolds with its work numbered in that order and
  how much of it is done; finished work turns green. Rename or delete a bundle from inside it
  (deleting one only unpins its work). Bundles are yours alone.
- **On the right, the piece you picked**: its engagement and client, due date and who's on it, its
  status in one click (planned, in progress, in review, blocked, done), its details, and Open in
  Work for everything else.
- **Working through the day**: Done, and next marks it done and opens what comes after it: the
  next in the bundle you opened it from, else the next in your list. Skip to next moves on
  without changing it.
- **Pinning**: pin the piece on the right to one of your bundles (at the bottom) or to a new one,
  move it up or down its bundle, or unpin it.

## Agents

`show_my_day` (with `show`, `q` and `todo`), `create_my_day_bundle`, `rename_my_day_bundle`,
`delete_my_day_bundle`, `pin_to_my_day_bundle`, `move_in_my_day_bundle`,
`unpin_from_my_day_bundle` and `set_my_day_status`. "Working through someone's day" is offered to
agents as a workflow. An agent's bundles are its person's.

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
