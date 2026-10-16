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
          resources :pins, only: :create
          resources :bundles, only: %i[create update destroy] do
            resources :pins, only: %i[update destroy], param: :todo_id
          end
          resources :todos, only: [] do
            resource :status, only: :update
          end
        end
      end
    end

    initializer "my_day.helpers" do
      ActiveSupport.on_load(:action_view) { include MyDay::DaysHelper }
    end

    config.to_prepare do
      Runwell::Plugins.register :my_day, name: "My day", version: MyDay::VERSION,
        author: "Martin Business Consultants", enabled_by_default: false, requires: ">= 2.24.0",
        homepage: "https://github.com/Martin-Business-Consultants/plugin-my-day",
        description: "Your work in one list, searched and filtered, with the one you pick open beside it, and bundles " \
                     "of it pinned at the top in the order you mean to do it: a way to work through the day."
      # icon: arrived in Runwell 2.25; an older core would refuse it and fail to boot.
      nav_icon = Runwell::Plugins.method(:nav).parameters.any? { |_, name| name == :icon } ? { icon: "sun" } : {}
      Runwell::Plugins.nav :my_day, "My day", -> { my_day_day_path }, **nav_icon
      Runwell::Plugins.stylesheet :my_day, "my_day/my_day"
      Runwell::Plugins.agent_workflow :my_day, "Working through someone's day", <<~STEPS
        1. `show_my_day` for the work you lead or are on (show: open, today, week, done or all; q to search) in groups (late, today, this week, later, no date) and your bundles, each in the order to do it.
        2. `create_my_day_bundle` to start a bundle ("Before lunch"), `pin_to_my_day_bundle` to add work to one (at the bottom), `move_in_my_day_bundle` (direction up or down) to change its order, `unpin_from_my_day_bundle` to take it out.
        3. `set_my_day_status` to move a piece of work on (in_progress, in_review, blocked, done); as an agent, finish into in_review for the person to mark done.
      STEPS
    end
  end
end
