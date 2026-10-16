module MyDay
  # A Runwell plugin: it owns its tables (my_day_*), points at core records by id, and reaches the
  # core only through the plugin contract (docs/plugin-contract.md in Runwell). Remove it and
  # Runwell runs as before.
  class Engine < ::Rails::Engine
    # Routes join the app's route set (as my_day_*), so the core layout's helpers work on the
    # plugin's pages.
    initializer "my_day.routes" do |app|
      app.routes.append do
        scope "my-day", module: "my_day", as: "my_day" do
          get "/", to: "days#show", as: :day
          post "bulk/priorities", to: "bulk_priorities#create", as: :bulk_priorities
          delete "bulk/priorities", to: "bulk_priorities#destroy"
          # A drop posts (the drag-and-drop controller only posts): onto the priorities to add or
          # reorder, onto the list to take off.
          post "priorities/:todo_id", to: "priorities#create", as: :priority
          patch "priorities/:todo_id", to: "priorities#update"
          delete "priorities/:todo_id", to: "priorities#destroy"
          post "priorities/:todo_id/removal", to: "priorities#destroy", as: :priority_removal
          resources :todos, only: :update do
            resource :status, only: :update
          end
        end
      end
    end

    # Work marked done anywhere (here, the Work pages, the bulk bar, an agent) falls off everyone's
    # priorities, freeing its place. Events come from the core's EventPublishJob, after the change.
    initializer "my_day.events" do
      ActiveSupport::Notifications.subscribe("event.runwell") do |*, payload|
        event = payload[:event]
        next unless Runwell::Plugins.enabled?(:my_day) && event.kind == "todo.status" && event.subject_type == "Todo"
        next unless event.payload.to_h.with_indifferent_access[:to] == "done"

        MyDay::Pin.where(todo_id: event.subject_id).delete_all
      end
    end

    initializer "my_day.helpers" do
      ActiveSupport.on_load(:action_view) { include MyDay::DaysHelper }
    end

    config.to_prepare do
      Runwell::Plugins.register :my_day, name: "My day", version: MyDay::VERSION,
        author: "Martin Business Consultants", enabled_by_default: false, requires: ">= 2.25.4",
        homepage: "https://github.com/Martin-Business-Consultants/plugin-my-day",
        description: "Your work in one list, searched and filtered, with the one you pick open beside it, and the work " \
                     "you drag to the top as your priorities, in the order you mean to do it: a way to work through the day."
      # icon: arrived in Runwell 2.25; an older core would refuse it and fail to boot.
      nav_icon = Runwell::Plugins.method(:nav).parameters.any? { |_, name| name == :icon } ? { icon: "sun" } : {}
      Runwell::Plugins.nav :my_day, "My day", -> { my_day_day_path }, **nav_icon
      Runwell::Plugins.stylesheet :my_day, "my_day/my_day"
      Runwell::Plugins.agent_workflow :my_day, "Working through someone's day", <<~STEPS
        1. `show_my_day` for your priorities (in order) and the work you lead or are on (show: open, today, week, done or all; q to search) in groups (late, today, this week, later, no date).
        2. `add_my_day_priority` to put work in the priorities (at the end, or before another), `move_my_day_priority` (up or down) to change its order, `remove_my_day_priority` to take it off.
        3. `set_my_day_status` to move a piece of work on (in_progress, in_review, blocked, done); as an agent, finish into in_review for the person to mark done.
      STEPS
    end
  end
end
