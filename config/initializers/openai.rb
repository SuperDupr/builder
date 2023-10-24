require "openai"

OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.dig(:ai_keys, :open_ai)
end
