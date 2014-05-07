# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

r = Role.create([
    {:name => 'Admin'},
    {:name => 'Registered'},
])

# Some sample locations so that rake scrape works right away.

Location.create("id"=>1, "name"=>"Museum of Fine Arts, Boston", "url"=>"https://www.mfa.org/", "description"=>"The Museum of Fine Arts in Boston, Massachusetts, is one of the largest museums in the United States. It contains more than 450,000 works of art, making it one of the most comprehensive collections in the Americas. With more than one million visitors a year, it is (as of 2013) the 62nd most-visited art museum in the world.\n\nFounded in 1870, the museum moved to its current location in 1909. The museum is affiliated with an art academy, the School of the Museum of Fine Arts, and a sister museum, the Nagoya/Boston Museum of Fine Arts, in Nagoya, Japan. The director of the museum is Malcolm Rogers.", "image"=>"http://www.mfa.org/sites/default/files/imagecache/showcase_2/images/Fenway%20at%20dusk_0.jpg", "latitude"=>42.3394675, "longitude"=>-71.0948962)
Location.create("id"=>2, "name"=>"Peabody Essex Museum", "url"=>"http://www.pem.org", "description"=>"The mission of the Peabody Essex Museum is to celebrate outstanding artistic and cultural creativity by collecting, stewarding and interpreting objects of art and culture in ways that increase knowledge, enrich the spirit, engage the mind and stimulate the senses.", "image"=>"http://www.pem.org/writable/resources/image/feature/museum.jpg", "latitude"=>42.52173, "longitude"=>-70.89224)
Location.create("id"=>3, "name"=>"Isabella Stewart Gardner Museum", "url"=>"http://www.gardnermuseum.org/", "description"=>"The Museum exercises cultural and civic leadership by nurturing a new generation of talent in the arts and humanities; by delivering the works of creators and performers to the public; and by reaching out to involve and serve its community. The collection is at the center of this effort as an inspiring encounter with beauty and art.", "image"=>"http://www.gardnermuseum.org/FILE/2662.jpg", "latitude"=>42.338319, "longitude"=>-71.098763)
Location.create("id"=>4, "name"=>"Harvard Art Museums", "url"=>"http://www.harvardartmuseums.org/", "description"=>"The three museums that make up the Harvard Art Museums are entities in their own right, each with a particular focus and collection strength. They are linked through a common mission and a common administration.", "image"=>"http://www.harvardartmuseums.org/sites/harvardartmuseums.org/files/history.jpg", "latitude"=>42.374082, "longitude"=>-71.114183)

ScraperUrl.create("id"=>1, "url"=>"http://www.pem.org", "location_id"=>2, "name"=>"peabody")
ScraperUrl.create("id"=>2, "url"=>nil, "location_id"=>3, "name"=>"gardner")
ScraperUrl.create("id"=>3, "url"=>nil, "location_id"=>4, "name"=>"harvard")

TagSource.create(name: 'DBpedia')
