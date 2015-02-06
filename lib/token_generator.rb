class TokenGenerator
  ASCII = ('!'..'~')
  def self.generate
    Digest::SHA2.new.hexdigest rand_string.join
  end
  private
  def self.rand_string
    ASCII.to_a.shuffle.slice(0, 20)
  end
end
