require 'multi_json'

class JsonRequester < HttpRequester

    def self.access(endpoint, method, params)
        response = super(endpoint, method, params, 'application/json')
        self.load(response.body)
    end

    def self.load(text, symbolize_keys=true)
        MultiJson.load(text, :symbolize_keys => symbolize_keys)
    end

    def self.dump(hash_obj, outfile)
        File.open(outfile, 'w+') do |f|
            f << MultiJson.dump(hash_obj)
        end
    end
end
