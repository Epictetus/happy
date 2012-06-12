require 'happy-helpers'

module Happy
  class Controller
    # A collection of useful helper methods.
    #
    module Helpers
      # Load a whole bunch of helpers fromi HappyHelpers. This includes stuff
      # like url_for, link_to and more.
      include HappyHelpers::Helpers

      # Renders "something". This method takes a closer look at what this
      # "something" is and then dispatches to a more specific method.
      #
      def render(what, options = {}, &blk)
        case what
          when NilClass   then ''
          when String     then render_template(what, options, &blk)
          when Enumerable then what.map { |i| render(i, options, &blk) }.join
          else render_resource(what, options)
        end
      end

      # Render a template from the controller's view folder.
      #
      def render_template(name, variables = {}, &blk)
        path = options[:views] || './views'
        HappyHelpers::Templates.render(File.join(path, name), self, variables, &blk)
      end

      # Render a resource.
      #
      def render_resource(resource, options = {})
        # build name strings
        singular_name = resource.class.to_s.tableize.singularize
        plural_name   = singular_name.pluralize

        # set options
        options = {
          singular_name => resource
        }.merge(options)

        # render
        render_template("#{plural_name}/_#{singular_name}.html.haml", options)
      end

      alias_method :h, :escape_html
      alias_method :l, :localize
      alias_method :t, :translate
    end
  end
end
