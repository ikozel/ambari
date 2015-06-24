require 'chefspec'
require 'chefspec/berkshelf'
require 'rspec/its'
require 'simplecov'

RSpec.configure { |config|
  config.color = true
  config.disable_monkey_patching!
  config.expect_with :rspec do |expects| expects.syntax = :expect end
  config.formatter = :documentation
  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end
}

SimpleCov.start
ChefSpec::Coverage.start!

require_relative 'support/method_shared_context'

def library file:
  File.expand_path "../../libraries/#{ file }", __FILE__
end
