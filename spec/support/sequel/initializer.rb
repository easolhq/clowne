require "sequel"
db =
  if RUBY_PLATFORM.match?(/java/)
    "jdbc:sqlite::memory:"
  else
    "sqlite::memory:"
  end

SEQUEL_DB = Sequel.connect(db)

require_relative "./schema"
require_relative "./models"
