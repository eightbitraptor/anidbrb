class String  
  def to_anidb_data
    split("\n")[1].split("|")
  end
end