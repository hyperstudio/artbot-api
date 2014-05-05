namespace :export do
  desc "Exports models in MODELS ENV to format for db:seed."
  task :seeds_format => :environment do
    puts "\n"
    all_models = ENV['MODELS'].split(",")
    all_models.each do |m|
        klass = m.singularize.classify.constantize
        klass.order(:id).all.each do |instance|
           puts "#{klass}.create(#{instance.serializable_hash.delete_if {|key, value| ['created_at','updated_at','id'].include?(key)}.to_s.gsub(/[{}]/,'')})"
        end
    end
  end
end