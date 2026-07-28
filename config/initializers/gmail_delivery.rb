  # Configure native Rails SMTP to use Google's unblocked alternative port
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 2525,                          # Port 2525 safely bypasses Render's firewall!
    domain: "gmail.com",
    user_name: "kavya.actimize@gmail.com",
    password: ENV["MAIL_PASSWORD"],       # Reads your 16-character Gmail App Password cleanly
    authentication: :plain,
    enable_starttls_auto: true
  }

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.default_url_options = {
    host: "task-17-b.onrender.com",
    protocol: "https"
  }

  config.action_mailer.default_options = {
    from: "kavya.actimize@gmail.com"
  }
