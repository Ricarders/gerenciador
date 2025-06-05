Rails.application.config.to_prepare do
  if defined?(SolidCable::Record)
    SolidCable::Record.connects_to database: { writing: :primary, reading: :primary }
  end

#  if defined?(SolidQueue::Record)
#    SolidQueue::Record.connects_to database: { writing: :primary, reading: :primary }
#  end
end