RSpec.configure do |config|
  config.before(:each) do
    PaperTrail.enabled = false
  end
 
  config.before(:each, :versioning => true) do
    PaperTrail.enabled = true
    PaperTrail.whodunnit = Rails.application.config.paper_trail_default_whodunnit
  end
end