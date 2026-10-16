module MyDay
  # The day: your work on the left (bundles pinned at the top, then everything by when it's due,
  # searched and filtered), and the piece you picked on the right.
  class DaysController < ApplicationController
    allow_staff
    agent_tool :show_my_day, on: :show, title: "Show my day",
      description: "The work you lead or are on, in groups by when it's due (late, today, this week, later, no date, done), and your bundles, each in the order to do it. show: open (the default), today (due today or late), week, done (this week) or all. q: words in the title, its engagement or its client. todo: one to show in full, with what comes after it.",
      params: { show: Day::SHOWS.keys, q: "string", todo: "integer" },
      next_tools: %i[set_my_day_status pin_to_my_day_bundle create_my_day_bundle]

    def show
      @day = Day.new(person, show: params[:show], query: params[:q])
      @from_bundle = @day.bundles.find { it.id.to_s == params[:from_bundle].to_s }
      @todo = @day.find(params[:todo]) || @day.first
      @next = @day.after(@todo, bundle: @from_bundle) if @todo
    end
  end
end
