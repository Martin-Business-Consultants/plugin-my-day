day = @day
todo_json = lambda do |json, todo|
  json.merge! agent_ref(todo)
  json.extract! todo, :title, :status, :due_on
  json.late todo.status != "done" && todo.due_on.present? && todo.due_on < Date.current
  json.engagement todo.engagement.ref
  json.client todo.client.name
end
priorities = day.priority_todos

json.summary "#{priorities.size} #{"priority".pluralize(priorities.size)} (#{my_day_progress(priorities)}), " \
  "#{day.todos.size} #{"piece".pluralize(day.todos.size)} of work (#{MyDay::Day::SHOWS[day.show].downcase}" \
  "#{", matching “#{day.query}”" if day.query.present?})#{"; open: #{@todo.title}" if @todo}"
json.show day.show
json.q day.query.presence
json.priorities priorities do |todo|
  todo_json.call(json, todo)
end
json.groups day.groups do |group|
  json.extract! group, :key, :title
  json.todos group.todos do |todo|
    todo_json.call(json, todo)
  end
end
if @todo
  json.todo do
    todo_json.call(json, @todo)
    json.description agent_text(@todo.description)
    json.priority priorities.index(@todo)&.then { it + 1 }
  end
end
