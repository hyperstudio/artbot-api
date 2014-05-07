class Map
  def initialize(mappable)
    @mappable = mappable
  end

  def image(image_size)
    '//maps.googleapis.com/maps/api/staticmap?' + query_params(image_size)
  end

  private

  def query_params(image_size)
    [scale, markers, zoom, sensor, size(image_size), api_key].compact.join('&')
  end

  def size(image_size)
    "size=#{dimensions.fetch(image_size)}"
  end

  def dimensions
    {
      small: '250x150',
      medium: '350x200',
      large: '531x260'
    }
  end

  def markers
    "markers=#{@mappable.latitude},#{@mappable.longitude}"
  end

  def zoom
    'zoom=15'
  end

  def sensor
    'sensor=false'
  end

  def scale
    'scale=2'
  end

  def api_key
    if google_browser_api_key
      "key=#{google_browser_api_key}"
    end
  end

  def google_browser_api_key
    ENV['GOOGLE_BROWSER_API_KEY']
  end
end

