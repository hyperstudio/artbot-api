FactoryGirl.define do
  factory :event do
    location
    sequence(:name) { |n| "Event #{n}" }
    dates 'May 20, 2014 - June 1, 2014'
  end

  factory :location do
    name "Museum of Fine Arts, Boston"
    url "https://www.mfa.org/"
    description "The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers."
    image "http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg"
    latitude 42.3394675
    longitude -71.0948962
  end
end