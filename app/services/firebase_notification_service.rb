require "googleauth"
require "net/http"
require "json"

class FirebaseNotificationService

  FIREBASE_SCOPE =
    "https://www.googleapis.com/auth/firebase.messaging"

  def self.send_notification(device_token, title, body)
    raise ArgumentError, "FCM device token is missing" if device_token.blank?

    project_id = ENV["FIREBASE_PROJECT_ID"]

    raise "FIREBASE_PROJECT_ID is not configured" if project_id.blank?

    key_path =
      if Rails.env.production?
        "/etc/secrets/serviceAccountKey.json"
      else
        Rails.root.join("config", "serviceAccountKey.json").to_s
      end

    unless File.exist?(key_path)
      raise "Firebase service account file not found: #{key_path}"
    end

    # --------------------------------------------------
    # Create Google credentials
    # --------------------------------------------------

    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(key_path),
      scope: FIREBASE_SCOPE
    )

    authorizer.fetch_access_token!

    access_token = authorizer.access_token

    # --------------------------------------------------
    # Firebase FCM URL
    # --------------------------------------------------

    uri = URI(
      "https://fcm.googleapis.com/v1/projects/#{project_id}/messages:send"
    )

    # --------------------------------------------------
    # HTTP request
    # --------------------------------------------------

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)

    request["Authorization"] = "Bearer #{access_token}"
    request["Content-Type"] = "application/json"

    # --------------------------------------------------
    # FCM payload
    # --------------------------------------------------

    request.body = {
      message: {
        token: device_token,

        notification: {
          title: title.to_s,
          body: body.to_s
        },

        # Optional data for frontend
        data: {
          title: title.to_s,
          body: body.to_s,
          type: "leave"
        }
      }
    }.to_json

    # --------------------------------------------------
    # Send request
    # --------------------------------------------------

    response = http.request(request)

    response_body =
      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        {
          "raw_response" => response.body
        }
      end

    # --------------------------------------------------
    # Success
    # --------------------------------------------------

    if response.is_a?(Net::HTTPSuccess)

      Rails.logger.info(
        "FCM notification sent successfully"
      )

      return true
    end

    # --------------------------------------------------
    # Invalid / expired FCM token
    # --------------------------------------------------

    if response_body.to_s.include?("UNREGISTERED")

      Rails.logger.error(
        "FCM token is UNREGISTERED: #{device_token}"
      )

      raise StandardError,
            "UNREGISTERED: FCM token is no longer valid"
    end

    # --------------------------------------------------
    # Other Firebase errors
    # --------------------------------------------------

    Rails.logger.error(
      "FCM notification failed. HTTP #{response.code}: #{response.body}"
    )

    raise StandardError,
          "FCM notification failed: #{response.body}"
  end

end