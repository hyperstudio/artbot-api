class Guest
  def favorited_events
    Event.newest(5)
  end
end
