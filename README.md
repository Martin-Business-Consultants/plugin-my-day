# My day for Runwell

The work assigned to you in one list, and the piece you pick open beside it: a way to work through
the day.

A Runwell plugin (Runwell's `docs/plugins.md`): a Rails engine that owns its `my_day_*` tables,
points at people and work by id, and extends the core only through the plugin contract. Needs
Runwell 2.25.2 or newer.

## Install

Settings › Plugins › Install, with `Martin-Business-Consultants/plugin-my-day`, or from the shell:

    bin/rails "plugins:install[Martin-Business-Consultants/plugin-my-day]"

Then switch it on in Settings › Plugins.

## What it does

- **My day**, in the nav: two columns, half and half.
- **On the left, your work**: everything you lead or are on, grouped by when it's due (late,
  today, this week, later, no date), oldest first in each, each with its state, where it's from
  and when it's due (late ones in red). A search box above it (as you type: the title, its
  engagement or its client) and a filter: everything open, due today or late, due this week, done
  this week, or everything.
- **Priorities, at the top**: a drop area that gathers the day's priorities, five at most, with
  its free places shown. Drag work onto it (in the order you'll do it, or drag within it to
  reorder), and drag it back onto the list to take it off. Click it to unfold its work, numbered,
  with how much is done; finished work turns green. Your priorities are yours alone.
- **On the right, the piece you picked**: a card with its engagement and client, due date and
  who's on it, its status in one click (planned, in progress, in review, blocked, done), its
  details, its place in your priorities (add, move up or down, remove: the same without dragging)
  and Open in Work; under it, its notes, with the composer to add one.

## Agents

`show_my_day` (with `show`, `q` and `todo`), `add_my_day_priority` (with `before`),
`move_my_day_priority`, `remove_my_day_priority` and `set_my_day_status`. "Working through
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
