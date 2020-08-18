require 'slack-notifier'

class SlackNotifier
  def self.ping(message)
    slack = Slack::Notifier.new ENV['WEBHOOK_SLACK_WEBHOOK']
    slack.ping message unless ENV['RACK_ENV'] == 'test'
  end
end