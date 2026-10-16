day = @day
todo_json = lambda do |json, todo|
  json.merge! agent_ref(todo)
  json.extract! todo, :title, :status, :due_on
  json.late todo.status != "done" && todo.due_on.present? && todo.due_on < Date.current
  json.engagement todo.engagement.ref
  json.client todo.client.name
end

json.summary "#{day.todos.size} #{"piece".pluralize(day.todos.size)} of work (#{MyDay::Day::SHOWS[day.show].downcase}" \
  "#{", matching “#{day.query}”" if day.query.present?}), #{day.bundles.size} #{"bundle".pluralize(day.bundles.size)}" \
  "#{"; open: #{@todo.title}" if @todo}"
json.show day.show
json.q day.query.presence
json.bundles day.bundles do |bundle|
  todos = bundle.todos_from(day.pinned_todos)
  json.extract! bundle, :id, :name
  json.progress my_day_progress(todos)
  json.todos todos do |todo|
    todo_json.call(json, todo)
  end
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
    json.bundles day.bundles_for(@todo).map(&:name)
    json.next(@next && { id: @next.id, title: @next.title })
  end
end
