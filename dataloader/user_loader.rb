require "json"


module Dataloader
  class UserLoader
    FIXTURE_PATH = File.join(__dir__, "fixtures", "users.json")

    def self.load_users
      JSON.parse(File.read(FIXTURE_PATH), symbolize_names: true)
    end

    def self.get_user(key)
      users = load_users
      users.fetch(key.to_sym) do
        raise KeyError, "No fixture user named '#{key}'. Available: #{users.keys}"
      end
    end
  end
end
