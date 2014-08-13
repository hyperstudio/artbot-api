module CurbHelpers
  def post_to_api(path, parameters)
    Curl.post("http://#{host}:#{port}#{path}", parameters) do |curl|
      set_default_headers(curl)

      yield curl if block_given?
    end
  end

  def delete_via_api(url, parameters)
    Curl.delete("http://#{host}:#{port}/#{url}", parameters) do |curl|
      set_default_headers(curl)

      yield curl if block_given?
    end
  end

  def get_from_api(url, parameters = {})
    Curl.get("http://#{host}:#{port}/#{url}", parameters) do |curl|
      set_default_headers(curl)

      yield curl if block_given?
    end
  end

  def patch_to_api(url, parameters = {})
    Curl.patch("http://#{host}:#{port}/#{url}", parameters) do |curl|
      set_default_headers(curl)

      yield curl if block_given?
    end
  end

  def parse_response_from(curb)
    JSON.parse(curb.body)
  end

  private

  def host
    Capybara.current_session.server.host
  end

  def port
    Capybara.current_session.server.port
  end

  def set_default_headers(curl)
    curl.headers['Accept'] = 'application/json'
  end
end
