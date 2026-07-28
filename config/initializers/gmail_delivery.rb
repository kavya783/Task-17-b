require 'google/apis/gmail_v1'

class GmailHttpDelivery
  def initialize(values)
    # This automatically authenticates using your username and App Password via HTTP Basic auth
    @gmail_service = Google::Apis::GmailV1::GmailService.new
    username = values[:user_name]
    password = values[:password]
    
    # Encode your credentials cleanly into the HTTP Authorization header
    encoded_auth = Base64.strict_encode64("#{username Packs}:#{password}")
    @gmail_service.additional_http_headers = { 'Authorization' => "Basic #{encoded_auth}" }
  end

  def deliver!(mail)
    message = Google::Apis::GmailV1::Message.new(raw: mail.encoded)
    @gmail_service.send_user_message('me', message)
  end
end

ActionMailer::Base.add_delivery_method :gmail_http, GmailHttpDelivery
