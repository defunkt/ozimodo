# for an accept header of text/plain
module Mime
  TEXT = Type.new "text/plain", :text
  LOOKUP["text/plain"] = TEXT
end
class ActionController::MimeResponds::Responder
  def text(&block)
    custom(Mime::TEXT, &block)
  end
end
