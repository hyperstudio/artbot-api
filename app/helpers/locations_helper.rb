module LocationsHelper
  def google_map_url_for(location)
    coordinates = [location.latitude, location.longitude].join(',')
    "//maps.google.com/maps?#{base_google_map_url_params.to_query}&q=loc:#{coordinates}"
  end

  def google_map_image_url_for(location)
    Map.new(location).image(:small)
  end

  private

  def base_google_map_url_params
    {
      t: 'm',
      z: 12,
    }
  end
end
