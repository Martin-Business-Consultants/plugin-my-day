module MyDay
  # Your bundles: named, ordered groups of work pinned at the top of your day.
  class BundlesController < ApplicationController
    allow_staff
    agent_tool :create_my_day_bundle, on: :create, title: "Start a bundle in my day",
      description: "A named group of work at the top of your day (\"Before lunch\", \"Acme launch\"), in the order you mean to do it. todo_id: pin that piece of work in it straight away.",
      params: { bundle: { name: "string!" }, todo_id: "integer" }, next_tools: %i[pin_to_my_day_bundle show_my_day]
    agent_tool :rename_my_day_bundle, on: :update, title: "Rename a bundle in my day",
      params: { bundle: { name: "string!" } }
    agent_tool :delete_my_day_bundle, on: :destroy, title: "Delete a bundle from my day",
      description: "Unpins its work; the work itself stays as it is."

    before_action :set_bundle, only: %i[update destroy]

    def create
      bundle = Bundle.start(person, name: params.expect(bundle: [ :name ])[:name])
      return back_to_day(alert: bundle.errors.full_messages.to_sentence) unless bundle.persisted?

      if (todo = Todo.find_by(id: params[:todo_id]))
        bundle.pin(todo)
        back_to_day(todo: todo.id, bundle: bundle.id, notice: "“#{todo.title}” pinned to #{bundle.name}.")
      else
        back_to_day(notice: "#{bundle.name} started: pin work to it from the right.")
      end
    end

    def update
      if @bundle.update(params.expect(bundle: [ :name ]))
        back_to_day(notice: "Renamed #{@bundle.name}.")
      else
        back_to_day(alert: @bundle.errors.full_messages.to_sentence)
      end
    end

    def destroy
      @bundle.destroy!
      back_to_day(bundle: nil, notice: "#{@bundle.name} deleted; its work is still yours.")
    end
  end
end
