class Version
  include MongoMapper::Document
  include ActiveModel::Observing

  key :data, Hash
  key :date, Time
  key :pos, Integer
  key :doc_id, ObjectId
  key :message, String
  key :updater_id, ObjectId

  def content(key)
    cdata = self.data[key]
    if cdata.respond_to?(:join)
      cdata.join(" ")
    else
      cdata
    end
  end


  def self.create_indexes
    ensure_index [[:doc_id, 1], [:pos, -1]]
  end
end
