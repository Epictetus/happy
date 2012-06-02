module Happy
  class Controller
    module Actions
      def serve!(data, options = {})
        # Don't serve if there are still bits of path remaining.
        return unless remaining_path.empty?

        # Don't serve is data is not a string.
        return unless data.is_a?(String)

        # Mix in default options
        options = {
          :layout => context.layout
        }.merge(options)

        # Add status code from options
        response.status = options.delete(:status) if options.has_key?(:status)

        # Extract layout
        layout = options.delete(:layout)

        # Treat remaining options as headers
        options.each { |k, v| header k, v }

        # Apply layout, if available
        if layout
          data = render(layout) { data }
        end

        # Set response body and finish request
        response.body = [data]
        halt!
      end

      def halt!(message = :done)
        throw message
      end

      def redirect!(to, status = 302)
        header :location, url_for(to)
        response.status = status
        halt!
      end

      def layout(name)
        context.layout = name
      end

      def content_type(type)
        header :content_type, type
      end

      def max_age(t, options = {})
        options = {
          :public => true,
          :must_revalidate => true
        }.merge(options)

        s = []
        s << 'public' if options[:public]
        s << 'must-revalidate' if options[:must_revalidate]
        s << "max-age=#{t.to_i}"

        cache_control s.join(', ')
      end

      def cache_control(s)
        header :cache_control, s
      end

      def header(name, value)
        name = name.to_s.dasherize.humanize if name.is_a?(Symbol)
        response[name] = value
      end

      def run(thing, options = {}, &blk)
        if thing.is_a?(Class) && thing.ancestors.include?(Happy::Controller)
          # Happy controllers!
          thing.new(env, options, &blk).perform
        elsif thing.respond_to?(:call)
          # Rack apps!
          context.response = thing.call(request.env)
          halt!
        elsif thing.respond_to?(:to_s)
          thing.to_s
        else
          raise "Don't know how to run #{thing.inspect} :("
        end
      end
    end
  end
end