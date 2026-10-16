module MyDay
  # A person's day: the open work they lead or are on, found by search and narrowed by when it's
  # due, in groups to work down (late, today, this week, later, no date), and their bundles.
  class Day
    SHOWS = { "open" => "Everything open", "today" => "Due today or late", "week" => "Due this week",
              "done" => "Done this week", "all" => "Everything" }.freeze
    Group = Data.define(:key, :title, :todos)

    attr_reader :user, :show, :query

    def initialize(user, show: nil, query: nil)
      @user = user
      @show = show.presence_in(SHOWS.keys) || "open"
      @query = query.to_s.strip.first(100)
    end

    def todos
      @todos ||= begin
        scope = Todo.assigned_to(user).includes(:owner, { assignments: :user }, engagement: :client)
        scope = filtered(scope)
        scope = searched(scope) if query.present?
        scope.order(Arel.sql("todos.due_on IS NULL"), :due_on, :id).to_a
      end
    end

    def groups
      today = Date.current
      week = today + 7
      buckets = todos.group_by do |todo|
        if todo.status == "done" then "done"
        elsif todo.due_on.nil? then "undated"
        elsif todo.due_on < today then "late"
        elsif todo.due_on == today then "today"
        elsif todo.due_on <= week then "week"
        else "later"
        end
      end
      { "late" => "Late", "today" => "Today", "week" => "This week", "later" => "Later", "undated" => "No date", "done" => "Done" }
        .filter_map { |key, title| Group.new(key: key, title: title, todos: buckets[key]) if buckets[key] }
    end

    def bundles = @bundles ||= Bundle.for(user).includes(:pins).to_a

    # Every pinned todo, looked up once, still open or not, whatever the filter.
    def pinned_todos
      @pinned_todos ||= Todo.where(id: bundles.flat_map { it.pins.map(&:todo_id) }.uniq)
        .includes(:owner, { assignments: :user }, engagement: :client).index_by(&:id)
    end

    def bundles_for(todo) = bundles.select { |bundle| bundle.pins.any? { it.todo_id == todo.id } }
    def pinned?(todo) = pinned_todos.key?(todo.id)

    # The todo on the right: the one asked for if this person may see it, else the first still to
    # do (a bundle's first, then the list's).
    def find(id)
      return if id.blank?

      pinned_todos[id.to_i] || todos.find { it.id == id.to_i } || Todo.assigned_to(user).includes(engagement: :client).find_by(id: id)
    end

    def first
      bundles.flat_map { it.todos_from(pinned_todos) }.find { it.status != "done" } || todos.find { it.status != "done" } || todos.first
    end

    # What comes after a todo: the next one still to do in the bundle it was opened from, else
    # in the list.
    def after(todo, bundle: nil)
      list = bundle ? bundle.todos_from(pinned_todos) : groups.flat_map(&:todos)
      index = list.index(todo)
      (index ? list.drop(index + 1) : list).find { it.status != "done" && it != todo }
    end

    private
      def filtered(scope)
        case show
        when "open" then scope.open
        when "today" then scope.open.where(due_on: ..Date.current)
        when "week" then scope.open.where(due_on: ..(Date.current + 7))
        when "done" then scope.where(status: "done", completed_at: 7.days.ago..)
        else scope
        end
      end

      def searched(scope)
        term = "%#{ActiveRecord::Base.sanitize_sql_like(query.downcase)}%"
        scope.joins(engagement: :client)
          .where("LOWER(todos.title) LIKE :term OR LOWER(engagements.title) LIKE :term OR LOWER(clients.name) LIKE :term", term: term)
      end
  end
end
