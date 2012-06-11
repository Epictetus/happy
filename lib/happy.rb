require 'rack'
require 'happy/version'
require 'happy/errors'
require 'happy/controller'

module Happy
  def self.env
    ActiveSupport::StringInquirer.new(ENV['RACK_ENV'] || 'development')
  end

  # Creates a new Happy::Controller class, using the provided block as
  # its routing block.
  #
  def self.route(&blk)
    Class.new(Happy::Controller).tap do |klass|
      klass.send(:define_method, :route, &blk)
    end
  end
end
