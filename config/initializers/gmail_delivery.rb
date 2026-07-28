require 'google/apis/gmail_v1'

class GmailHttpDelivery
  def initialize(values = {})
    @gmail_service = Google::Apis::GmailV1::GmailService.new
    
    username = "kavya.actimize@gmail.com"
    password = ENV["MAIL_PASSWORD"]
    
    # FIXED: The word Packs has been completely removed here
    encoded_auth = Base64.strict_encode64("#{username}:#{password}")
    @gmail_service.additional_http_headers = { 'Authorization' => "Basic #{encoded_auth}" }
  end

  def deliver!(mail)
    message = Google::Apis::GmailV1::Message.new(raw: mail.encoded)
    @gmail_service.send_user_message('me', message)
  end
end

ActionMailer::Base.add_delivery_method :gmail_http, GmailHttpDelivery
