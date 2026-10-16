module MyDay
  # A person's bundle: work pinned together at the top of their day ("Before lunch", "Acme
  # launch"), in the order they mean to do it. Only its person sees it.
  class Bundle < ApplicationRecord
    belongs_to :user
    has_many :pins, -> { order(:position, :id) }, dependent: :delete_all, inverse_of: :bundle

    normalizes :name, with: ->(name) { name.strip }
    validates :name, presence: true, length: { maximum: 80 }

    scope :ordered, -> { order(:position, :id) }

    def self.for(user) = where(user: user).ordered

    def self.start(user, name:)
      create(user: user, name: name, position: (where(user: user).maximum(:position) || 0) + 1)
    end

    # The bundle's todos in its order, from todos looked up once for every bundle on the page
    # ({ id => todo }); a todo gone from the core is skipped.
    def todos_from(todos_by_id) = pins.filter_map { todos_by_id[it.todo_id] }

    # Puts a todo at the bottom of the bundle (once: pinning it again leaves it where it is).
    def pin(todo)
      pins.find_or_create_by(todo_id: todo.id) { it.position = (pins.maximum(:position) || 0) + 1 }
    end

    def unpin(todo) = pins.where(todo_id: todo.id).delete_all

    # One place up or down the bundle's order, swapping with its neighbour.
    def move(todo, direction)
      list = pins.to_a
      index = list.index { it.todo_id == todo.id } or return false
      other = list[direction.to_s == "up" ? index - 1 : index + 1]
      return false if other.nil? || (direction.to_s == "up" && index.zero?)

      list.each_with_index { |pin, at| pin.position = at }
      list[index].position, other.position = other.position, list[index].position
      transaction { list.each { it.save! if it.position_changed? } }
      true
    end

    def to_s = name
  end
end
