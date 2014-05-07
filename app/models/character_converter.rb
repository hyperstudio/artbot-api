class CharacterConverter
  def self.convert_to_unicode(content)
    if ! content.valid_encoding?
      content.unpack("C*").pack("U*")
    else
      content
    end
  end
end
