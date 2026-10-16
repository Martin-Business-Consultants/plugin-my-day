module MyDay
  module DaysHelper
    STATUS_LABELS = { "planned" => "Planned", "in_progress" => "In progress", "in_review" => "In review",
                      "blocked" => "Blocked", "done" => "Done" }.freeze

    # A link to the day with this todo open, keeping the filter and search.
    def my_day_todo_path(todo)
      my_day_day_path({ todo: todo.id, show: params[:show], q: params[:q] }.compact_blank)
    end

    # The day's filter and search, carried by a form so it comes back to the same view.
    def my_day_return_params = { show: params[:show], q: params[:q] }.compact_blank

    def my_day_status_label(todo) = STATUS_LABELS.fetch(todo.status, todo.status.humanize)

    # A todo's state in the list: a green check once done, else a dot in its status's colour.
    def my_day_marker(todo)
      if todo.status == "done"
        tag.span icon_tag("check"), class: "my-day-check", title: "Done"
      else
        tag.span class: "my-day-dot my-day-dot--#{todo.status}", title: my_day_status_label(todo)
      end
    end

    # When it's due, in words: late ones say so.
    def my_day_due(todo)
      return if todo.due_on.nil?

      today = Date.current
      text = case todo.due_on
      when today then "Today"
      when today + 1 then "Tomorrow"
      when today - 1 then "Yesterday"
      when (today + 2)..(today + 6) then todo.due_on.strftime("%a")
      else todo.due_on.strftime("%-d %b")
      end
      late = todo.status != "done" && todo.due_on < today
      tag.span(late ? "Late · #{text}" : text, class: class_names("my-day-due", "my-day-due--late": late))
    end

    # "2 of 5 done" for the priorities.
    def my_day_progress(todos)
      "#{todos.count { it.status == "done" }} of #{todos.size} done"
    end
  end
end
