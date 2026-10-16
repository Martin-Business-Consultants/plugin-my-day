module MyDay
  # The day: your work on the left (your priorities at the top, then everything by when it's due,
  # searched and filtered), and the piece you picked on the right.
  class DaysController < ApplicationController
    allow_staff
    agent_tool :show_my_day, on: :show, title: "Show my day",
      description: "Your priorities (the work you've put at the top of your day, in order), then the work you lead or are on in groups by when it's due (late, today, this week, later, no date, done). show: open (the default), today (due today or late), week, done (this week) or all. q: words in the title, its engagement or its client. todo: one to show in full.",
      params: { show: Day::SHOWS.keys, q: "string", todo: "integer" },
      next_tools: %i[add_my_day_priority set_my_day_status]

    def show
      load_day
      @open = session.delete(:my_day_open)
    end
  end
end
