require 'net/http'
require 'multi_json'

class JsonRequester

    def access_json(endpoint, method, params, limit=10)
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
        request['accept'] = 'application/json'
        response = Net::HTTP.start(url.host, url.port) {|http|
            http.request(request)
        }

        # Handle redirects recursively
        case response
        when Net::HTTPRedirection then
            self.access_json(response['location'], method, params, limit-1)
        end

        return MultiJson.load(response.body)
    end

    def get(endpoint, params)
        self.access_json(endpoint, "GET", params)
    end

    def post(endpoint, data)
        self.access_json(endpoint, "POST", data)
    end

end