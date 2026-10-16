module MyDay
  # A person's priorities: the work they've dragged to the top of their day, in the order they mean
  # to do it. One each, made the first time it's needed. Only its person sees it.
  class Bundle < ApplicationRecord
    NAME = "Priorities".freeze
    LIMIT = 5

    belongs_to :user
    has_many :pins, -> { order(:position, :id) }, dependent: :delete_all, inverse_of: :bundle

    normalizes :name, with: ->(name) { name.strip }
    validates :name, presence: true, length: { maximum: 80 }

    scope :ordered, -> { order(:position, :id) }

    def self.priorities_for(user) = where(user: user).ordered.first || create!(user: user, name: NAME)

    # Its todos in order, from todos looked up once ({ id => todo }); one gone from the core is
    # skipped.
    def todos_from(todos_by_id) = pins.filter_map { todos_by_id[it.todo_id] }

    def include?(todo) = pins.any? { it.todo_id == todo.id }
    def full? = pins.size >= LIMIT

    # Puts a todo just before another (a todo id), or at the end: added if it wasn't here, moved
    # if it was. Five at most: a sixth isn't added (false).
    def place(todo, before: nil)
      list = pins.to_a
      return false if full? && !include?(todo)

      pin = list.find { it.todo_id == todo.id } || pins.build(todo_id: todo.id)
      list.delete(pin)
      at = list.index { it.todo_id.to_s == before.to_s } if before.present?
      list.insert(at || list.size, pin)
      renumber(list)
    end

    def unpin(todo) = pins.where(todo_id: todo.id).delete_all

    # One place up or down, swapping with its neighbour.
    def move(todo, direction)
      list = pins.to_a
      index = list.index { it.todo_id == todo.id } or return false
      other = direction.to_s == "up" ? index - 1 : index + 1
      return false unless other.between?(0, list.size - 1)

      list[index], list[other] = list[other], list[index]
      renumber(list)
    end

    def to_s = name

    private
      def renumber(list)
        transaction do
          list.each_with_index do |pin, index|
            pin.position = index
            pin.save! if pin.new_record? || pin.position_changed?
          end
        end
        pins.reset
        true
      end
  end
end
