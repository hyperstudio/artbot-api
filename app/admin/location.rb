ActiveAdmin.register Location do
    permit_params :name, :url, :description, :image, :latitude, :longitude, :address, :hours
end
