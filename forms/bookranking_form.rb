require 'virtus'
require 'active_model'

##
# String attribute for form objects of TutorialForm
class StringStripped < Virtus::Attribute
  def coerce(value)
    value.is_a?(String) ? value.strip : nil
  end
end

##
# Array<String> attribute for form objects of TutorialForm
class ArrayOfNames < Virtus::Attribute
  def coerce(value)
    value.is_a?(String) ?
      value.split("\r\n").map(&:strip).reject(&:empty?) : nil
  end
end

##
# Form object
class BookrankingForm
  include Virtus.model
  include ActiveModel::Validations

  attribute :booknames, StringStripped
  # attribute :rank, StringStripped
  # attribute :price_description, StringStripped
  # attribute :price, StringStripped
  # attribute :author, StringStripped
  attribute :date, Date
  # attribute :source, StringStripped
  # attribute :prod_id, StringStripped

  validates :booknames, presence: true
  # validates :rank, presence: true
  # validates :price_description, presence: true
  # validates :price, presence: true
  # validates :author, presence: true
  validates :date, presence: true
  # validates :source, presence: true
  # validates :prod_id, presence: true

  def error_fields
    errors.messages.keys.map(&:to_s).join(', ')
  end
end
