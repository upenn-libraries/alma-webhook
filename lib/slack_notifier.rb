class SlackNotifier
  attr_reader :slack

  def initialize
    @slack = Slack::Notifier.new ENV['WEBHOOK_SLACK_WEBHOOK']
  end

  def ping(message)
    slack.ping message unless ENV['RACK_ENV'] == 'test'
  end
end