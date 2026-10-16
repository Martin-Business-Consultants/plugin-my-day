module MyDay
  # A todo in a bundle, at its place in the bundle's order. Points at the core's todo by id.
  class Pin < ApplicationRecord
    belongs_to :bundle, inverse_of: :pins

    validates :todo_id, uniqueness: { scope: :bundle_id }
  end
end
