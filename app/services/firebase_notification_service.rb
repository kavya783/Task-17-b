require "googleauth"
require "net/http"
require "json"

class FirebaseNotificationService

  def self.send_notification(device_token, title, body)

    project_id = ENV["FIREBASE_PROJECT_ID"]

    raise "FIREBASE_PROJECT_ID is missing" if project_id.blank?

    scope = [
      "https://www.googleapis.com/auth/firebase.messaging"
    ]

    key_path =
      if Rails.env.production?
        "/etc/secrets/serviceAccountKey.json"
      else
        Rails.root.join(
          "config",
          "serviceAccountKey.json"
        )
      end

    authorizer =
      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(key_path),
        scope: scope
      )

    authorizer.fetch_access_token!

    access_token = authorizer.access_token

    uri = URI(
      "https://fcm.googleapis.com/v1/projects/" \
      "#{project_id}/messages:send"
    )

    http = Net::HTTP.new(
      uri.host,
      uri.port
    )

    http.use_ssl = true

    request = Net::HTTP::Post.new(
      uri.request_uri
    )

    request["Authorization"] =
      "Bearer #{access_token}"

    request["Content-Type"] =
      "application/json"

    request.body = {
      message: {
        token: device_token,
        notification: {
          title: title,
          body: body
        }
      }
    }.to_json

    response = http.request(request)

    if response.code.to_i == 200

      Rails.logger.info(
        "FCM notification sent successfully"
      )

      true

    else

      Rails.logger.error(
        "FCM notification failed: #{response.body}"
      )

      raise StandardError, response.body
    end
  end
endrequire "googleauth"
require "net/http"
require "json"

class FirebaseNotificationService

  FIREBASE_SCOPE =
    "https://www.googleapis.com/auth/firebase.messaging"

  FIREBASE_URL =
    "https://fcm.googleapis.com/v1/projects/%{project_id}/messages:send"


  def self.send_notification(device_token, title, body)

    return false if device_token.blank?

    project_id = ENV["FIREBASE_PROJECT_ID"]

    if project_id.blank?
      Rails.logger.error(
        "FIREBASE_PROJECT_ID is missing"
      )

      return false
    end


    begin

      access_token = firebase_access_token

      uri = URI(
        FIREBASE_URL % {
          project_id: project_id
        }
      )


      http = Net::HTTP.new(
        uri.host,
        uri.port
      )

      http.use_ssl = true

      request = Net::HTTP::Post.new(
        uri.request_uri
      )


      request["Authorization"] =
        "Bearer #{access_token}"

      request["Content-Type"] =
        "application/json"


      request.body = {
        message: {
          token: device_token,

          notification: {
            title: title,
            body: body
          }
        }
      }.to_json


      response = http.request(request)


      response_code =
        response.code.to_i


      # ==========================================
      # SUCCESS
      # ==========================================

      if response_code == 200

        Rails.logger.info(
          "FCM notification sent successfully"
        )

        return true
      end


      # ==========================================
      # INVALID / EXPIRED DEVICE TOKEN
      # ==========================================

      response_body =
        JSON.parse(
          response.body
        ) rescue {}


      error_code =
        response_body.dig(
          "error",
          "details"
        )&.find do |detail|
          detail["@type"] ==
            "type.googleapis.com/google.firebase.fcm.v1.FcmError"
        end&.fetch(
          "errorCode",
          nil
        )


      if error_code == "UNREGISTERED"

        Rails.logger.warn(
          "FCM device token is unregistered. Removing token."
        )

        remove_device_token(
          device_token
        )

        return false
      end


      # ==========================================
      # OTHER FCM ERROR
      # ==========================================

      Rails.logger.error(
        "FCM notification failed: #{response.body}"
      )

      false


    rescue StandardError => error

      Rails.logger.error(
        "FCM service error: #{error.message}"
      )

      false

    end

  end


  private


  # ==========================================
  # GET FIREBASE ACCESS TOKEN
  # ==========================================

  def self.firebase_access_token

    Rails.cache.fetch(
      "firebase_access_token",
      expires_in: 50.minutes
    ) do

      key_path =
        if Rails.env.production?

          "/etc/secrets/serviceAccountKey.json"

        else

          Rails.root.join(
            "config",
            "serviceAccountKey.json"
          )

        end


      credentials =
        Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(key_path),
          scope: FIREBASE_SCOPE
        )


      credentials.fetch_access_token!

      credentials.access_token

    end

  end


  # ==========================================
  # REMOVE INVALID DEVICE TOKEN
  # ==========================================

  def self.remove_device_token(device_token)

    DeviceToken
      .where(token: device_token)
      .delete_all

    Rails.logger.info(
      "Invalid device token removed successfully"
    )

  rescue StandardError => error

    Rails.logger.error(
      "Failed to remove invalid device token: #{error.message}"
    )

  end

end