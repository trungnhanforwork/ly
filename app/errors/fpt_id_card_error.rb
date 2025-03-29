class FptIdCardError < StandardError
  attr_reader :error_code

  def initialize(message, error_code = nil)
    @error_code = error_code
    super(message)
  end
end
