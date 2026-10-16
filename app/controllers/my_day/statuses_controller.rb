module MyDay
  # Moving a piece of work on from your day, through the core's own verb (its history records it).
  class StatusesController < ApplicationController
    allow_staff
    agent_tool :set_my_day_status, on: :update, title: "Set a piece of work's status from my day",
      description: "planned, in_progress, in_review, blocked or done. As an agent, finish into in_review for a person to mark done.",
      params: { status: Todo::STATUSES }, next_tools: %i[show_my_day]

    def update
      todo = Todo.find(params[:todo_id])
      if change_status(todo, params.expect(:status))
        back_to_day(todo: todo.id, notice: "“#{todo.title}” is #{todo.status.humanize.downcase}.")
      else
        back_to_day(todo: todo.id, alert: todo.errors.full_messages.to_sentence)
      end
    end

    private
      # The core's verb. Its board orders look the todo up again as they move it, which the core's
      # own TodosController#update is excused for in development and test (Prosopite); so is this.
      def change_status(todo, status)
        save = -> { todo.update(status: status) }
        defined?(Prosopite) ? Prosopite.pause(&save) : save.call
      end
  end
end
