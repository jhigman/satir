module Sprat
  class Result

    include DataMapper::Resource

    property :id,           Serial
    property :params,  Text
    property :request,    Text
    property :response,    Text
    property :result,    Text
    property :reason,    Text

    belongs_to :job

  end
end