class Guest
  def favorited_events
    Event.order('created_at DESC').limit(5)
  end
end
