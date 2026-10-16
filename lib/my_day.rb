require "my_day/version"
require "my_day/engine"

# My day: the work assigned to you in one list, searched and filtered, with the one you pick open
# beside it, and bundles of it pinned at the top in the order you mean to do it.
module MyDay
  # Plugin tables are prefixed with the plugin's key.
  def self.table_name_prefix = "my_day_"
end
