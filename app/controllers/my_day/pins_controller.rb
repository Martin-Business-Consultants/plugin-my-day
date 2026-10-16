module MyDay
  # Work in one of your bundles: pinned at its bottom, moved up or down its order, or taken out.
  class PinsController < ApplicationController
    allow_staff
    agent_tool :pin_to_my_day_bundle, on: :create, title: "Pin work to a bundle in my day",
      description: "Adds a piece of work at the bottom of one of your bundles (once: pinning it again leaves it in place).",
      params: { bundle_id: "integer!", todo_id: "integer!" }, next_tools: %i[move_in_my_day_bundle show_my_day]
    agent_tool :move_in_my_day_bundle, on: :update, title: "Move work up or down a bundle in my day",
      description: "One place up or down the bundle's order.", params: { direction: [ "up", "down" ] }
    agent_tool :unpin_from_my_day_bundle, on: :destroy, title: "Unpin work from a bundle in my day",
      description: "Takes it out of the bundle; the work itself stays as it is."

    before_action :set_bundle
    before_action { @todo = Todo.find(params[:todo_id]) }

    def create
      @bundle.pin(@todo)
      back_to_day(todo: @todo.id, bundle: @bundle.id, notice: "“#{@todo.title}” pinned to #{@bundle.name}.")
    end

    def update
      if @bundle.move(@todo, params.expect(:direction))
        back_to_day(todo: @todo.id, bundle: @bundle.id, notice: "Moved “#{@todo.title}” #{params[:direction]} in #{@bundle.name}.")
      else
        back_to_day(todo: @todo.id, bundle: @bundle.id, alert: "“#{@todo.title}” can't go further #{params[:direction]} in #{@bundle.name}.")
      end
    end

    def destroy
      @bundle.unpin(@todo)
      back_to_day(todo: @todo.id, bundle: nil, notice: "“#{@todo.title}” unpinned from #{@bundle.name}.")
    end
  end
end
