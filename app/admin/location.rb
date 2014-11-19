ActiveAdmin.register Location do
  permit_params :name, :url, :description, :image, :latitude, :longitude, :address, :hours

  index do
    selectable_column
    id_column
    column :name
    column :url do |loc|
      link_to loc.url, loc.url, :target => :blank
    end
    column :description
    column :latitude
    column :longitude
    column :address
    column :hours
  end

  form do |f|
    f.actions
    f.inputs 'Locations' do |loc|
      f.input :name
      f.input :url
      f.input :description
      f.input :latitude
      f.input :longitude
      f.input :address
      f.input :image, :required => false, :hint => f.template.image_tag(f.object.image.url(:small))
      f.input :hours
    end
    f.actions
  end

  show do |ad|
    attributes_table do
      row :name
      row :url do |loc|
        link_to loc.url, admin_location_path(loc.id), :target => :blank
      end
      row :description
      row :latitude
      row :longitude
      row :address
      row :image do
        image_tag(ad.image.url(:small))
      end
      row :imageurl do
        link_to ad.image.url, ad.image.url, :target => :blank
      end
      row :hours
    end
  end

  batch_action :set_images_on, confirm: "Set images on selected", form: {url: :text} do |ids, inputs|
    Location.find(ids).each do |loc|
      loc.image = inputs['url']
      loc.save
    end
    redirect_to collection_path, notice: '%d locations with changed image' % ids.count
  end
end
