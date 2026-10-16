module MyDay
  # A person's day: the open work they lead or are on, found by search and narrowed by when it's
  # due, in groups to work down (late, today, this week, later, no date, then what's in review or
  # blocked), oldest first in each, and their priorities.
  class Day
    SHOWS = { "open" => "Everything open", "today" => "Due today or late", "week" => "Due this week",
              "done" => "Done this week", "all" => "Everything" }.freeze
    Group = Data.define(:key, :title, :todos)
    # Work waiting on someone else (a check, or whatever blocks it) goes to the bottom, in groups of
    # its own, below the work to do now.
    WAITING = %w[in_review blocked].freeze

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
        scope.order(:created_at, :id).to_a
      end
    end

    def groups
      today = Date.current
      week = today + 7
      buckets = todos.group_by do |todo|
        if todo.status == "done" then "done"
        elsif todo.status.in?(WAITING) then todo.status
        elsif todo.due_on.nil? then "undated"
        elsif todo.due_on < today then "late"
        elsif todo.due_on == today then "today"
        elsif todo.due_on <= week then "week"
        else "later"
        end
      end
      { "late" => "Late", "today" => "Today", "week" => "This week", "later" => "Later", "undated" => "No date",
        "in_review" => "In review", "blocked" => "Blocked", "done" => "Done" }
        .filter_map { |key, title| Group.new(key: key, title: title, todos: buckets[key]) if buckets[key] }
    end

    def priorities = @priorities ||= Bundle.priorities_for(user).tap { it.pins.load }

    # The priorities' todos in order, still open or not, whatever the filter or search.
    def priority_todos = @priority_todos ||= priorities.todos_from(pinned_todos)

    def pinned_todos
      @pinned_todos ||= Todo.where(id: priorities.pins.map(&:todo_id))
        .includes(:owner, { assignments: :user }, engagement: :client).index_by(&:id)
    end

    def priority?(todo) = priorities.include?(todo)

    # The todo on the right: the one asked for if this person may see it, else the first still to
    # do (the priorities' first, then the list's).
    def find(id)
      return if id.blank?

      pinned_todos[id.to_i] || todos.find { it.id == id.to_i } || Todo.assigned_to(user).includes(engagement: :client).find_by(id: id)
    end

    def first
      listed = groups.flat_map(&:todos)
      priority_todos.find { it.status != "done" } || listed.find { !it.status.in?([ "done", *WAITING ]) } || listed.first
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
