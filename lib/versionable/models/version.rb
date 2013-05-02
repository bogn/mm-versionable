class Version
  include MongoMapper::Document
  include ActiveModel::Observing

  key :data, Hash
  key :date, Time
  key :pos, Integer
  key :doc_id, ObjectId
  key :message, String
  key :updater_id, ObjectId
  key :activity, String # e.g. 'created' or 'updated'
  key :type, String


  def content(key)
    if key.include?(".")
      access_with_dot_syntax(key)
    else
      cdata = self.data[key]
      if cdata.respond_to?(:join)
        cdata.join(" ")
      else
        cdata
      end
    end

  end


  def self.create_indexes
    ensure_index [[:doc_id, 1], [:pos, -1]]
  end


  private


    def access_with_dot_syntax(key)
      parts = key.split('.')
      cdata = self.data[parts.shift] # get the first-level
      parts.each do |p|
        if p.to_i.to_s == p
          cdata = cdata[p.to_i]
        else
          cdata = cdata[p.to_s] || cdata[p.to_sym]
        end
        break unless cdata
      end
      cdata
    end
end
