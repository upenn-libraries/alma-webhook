class WebhookBibResponse
  def initialize(json)
    @json = json
    @data = JSON.parse json
  rescue StandardError => _e
    nil
  end

  # @return [String]
  def mms_id
    @data&.dig 'bib', 'mms_id'
  end

  # @return [TrueClass, FalseClass]
  def event
    @data&.dig 'event', 'value'
  end

  # @return [String]
  def title
    @data&.dig 'bib', 'title'
  end

  # @return [TrueClass, FalseClass]
  def delete?
    event == 'BIB_DELETED'
  end

  # @return [TrueClass, FalseClass]
  def update?
    event == 'BIB_UPDATED'
  end

  # @return [TrueClass, FalseClass]
  def create?
    event == 'BIB_CREATED'
  end

  def template
    <<~MARKDOWN
      #{event}: `#{mms_id}`, "#{title}"
    MARKDOWN
  end
end