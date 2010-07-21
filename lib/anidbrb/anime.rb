require 'date'

module AniDB
  class Anime
    class << self

      def find(id, anime_fields = nil)
        puts "getting anime information"
        anime_fields ||= DEFAULT_ANIME_AFIELDS
        amask = anime_fields.inject(0) { |m, k| m | ANIME_AMASKS[k] }.to_s(16)
        puts "processed amasks, getting result..."
        result = Session.new.send(:ANIME, :aid => id, :amask => amask).to_anidb_data
        self.new(anime_fields.zip(result))
      end
    end

    def initialize(data)
      data.each do |field|
        if field[0] == :aid
          var = field[1].split("\n")
        elsif field[0].to_s.match( /date/ )
          var = Time.at(field[1].to_i)
        else
          var=field[1].chomp
        end
        instance_variable_set("@#{field[0]}", var)
      end
    end
  end
end
