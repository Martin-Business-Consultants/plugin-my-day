module MyDay
  # Several pieces of work picked in the list (the bulk bar) put into your priorities, as far as
  # they hold, or taken off them.
  class BulkPrioritiesController < ApplicationController
    allow_staff
    agent_tool :bulk_add_my_day_priorities, on: :create, title: "Add several pieces of work to my priorities",
      description: "At the end, in the order given, as far as the priorities hold (five).", params: { ids: "integer[]!" },
      next_tools: %i[show_my_day]
    agent_tool :bulk_remove_my_day_priorities, on: :destroy, title: "Remove several pieces of work from my priorities",
      params: { ids: "integer[]!" }, next_tools: %i[show_my_day]

    before_action do
      @priorities = Bundle.priorities_for(person)
      ids = Array(params[:ids]).map(&:to_i)
      @todos = Todo.where(id: ids).index_by(&:id).values_at(*ids).compact
      @todos = @todos.reject { it.status == "done" } if action_name == "create"
    end

    def create
      skipped = @priorities.add(@todos)
      message = "#{@todos.size - skipped.size} added to your priorities"
      message += "; #{skipped.size} didn't fit (they hold #{Bundle::LIMIT})" if skipped.any?
      back_to_day(**(skipped.any? ? { alert: "#{message}." } : { notice: "#{message}." }))
    end

    def destroy
      @priorities.pins.where(todo_id: @todos.map(&:id)).delete_all
      back_to_day(notice: "#{@todos.size} taken off your priorities.")
    end
  end
end
