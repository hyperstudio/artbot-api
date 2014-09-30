require 'net/http'
require 'multi_json'

class HttpRequester

    def self.access(endpoint, method, params, mimetype=nil, limit=10)
        raise ArgumentError, 'too many HTTP redirects' if limit == 0
        
        url = URI.parse(endpoint)
        if method.upcase == "GET"
            # Treat params as a hash and encode into URL
            url.query = URI.encode_www_form(params)
            request = Net::HTTP::Get.new(url)
        elsif method.upcase == "POST"
            # Treat params as the post form data
            request = Net::HTTP::Post.new(url)
            request.set_form_data(params)
        else
            raise ArgumentError, 'invalid request method "%s"' % [method]
        end
        request['accept'] = mimetype unless mimetype.nil?
        response = Net::HTTP.start(url.host, url.port) {|http|
            http.request(request)
        }

        # Handle redirects recursively
        case response
        when Net::HTTPRedirection then
            self.access(response['location'], method, params, mimetype, limit-1)
        end

        response
    end

    def self.get(endpoint, params={})
        access(endpoint, "GET", params)
    end

    def self.post(endpoint, data={})
        access(endpoint, "POST", data)
    end
end