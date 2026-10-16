module MyDay
  # Changing the picked piece of work from your day: its due date and its details, through the
  # core's own model (its history, mentions and search follow as anywhere else).
  class TodosController < ApplicationController
    allow_staff
    agent_tool :update_my_day_todo, on: :update, title: "Change a piece of work from my day",
      description: "Its due date (blank to clear) or its details (rich text, @mentions welcome).",
      params: { todo: { due_on: "date", description: "text" } }, next_tools: %i[show_my_day]

    def update
      todo = Todo.find(params[:id])
      if todo.update(params.expect(todo: %i[due_on description]))
        back_to_day(todo: todo.id, notice: "“#{todo.title}” saved.")
      else
        back_to_day(todo: todo.id, alert: todo.errors.full_messages.to_sentence)
      end
    end
  end
end
