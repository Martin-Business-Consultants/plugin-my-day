module MyDay
  # Your priorities: work dragged (or added) to the top of your day, in order.
  class PrioritiesController < ApplicationController
    allow_staff
    agent_tool :add_my_day_priority, on: :create, title: "Add work to my priorities",
      description: "Puts a piece of work in your priorities at the top of your day: at the end, or just before another (before: its todo id). Already there? It moves. They hold five; a sixth is refused.",
      params: { before: "integer" }, next_tools: %i[show_my_day]
    agent_tool :move_my_day_priority, on: :update, title: "Move work up or down my priorities",
      description: "One place up or down.", params: { direction: [ "up", "down" ] }
    agent_tool :remove_my_day_priority, on: :destroy, title: "Remove work from my priorities",
      description: "Takes it off the top of your day; the work itself stays as it is."

    before_action do
      @priorities_open = true
      @todo = Todo.find(params[:todo_id])
      @priorities = Bundle.priorities_for(person)
    end

    def create
      if @todo.status == "done"
        back_to_day(alert: "“#{@todo.title}” is done: priorities are for what's still to do.")
      elsif @priorities.place(@todo, before: params[:before])
        back_to_day(notice: "“#{@todo.title}” is in your priorities.")
      else
        back_to_day(alert: "Your priorities hold #{Bundle::LIMIT}: take one off (or finish it) before adding “#{@todo.title}”.")
      end
    end

    def update
      if @priorities.move(@todo, params.expect(:direction))
        back_to_day(notice: "Moved “#{@todo.title}” #{params[:direction]}.")
      else
        back_to_day(alert: "“#{@todo.title}” can't go further #{params[:direction]}.")
      end
    end

    def destroy
      @priorities.unpin(@todo)
      back_to_day(notice: "“#{@todo.title}” is off your priorities.")
    end
  end
end
