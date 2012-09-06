RSpec::Matchers.define(:delegate) do |method|
  chain :to do |expected_delegate|
    @expected_delegate = expected_delegate
  end

  match do |actual| 
    raise "error: delegate matcher needs .to(expected_delegate)" unless @expected_delegate
    delegate_mock = @expected_delegate.to_s.camelize.constantize.new
    actual.send(:"#{@expected_delegate}=", delegate_mock)
    result = true
    begin
    if method.to_s.include?('=')
      delegate_mock.should_receive(method).with("some value")
      actual.send(method, "some value")
    else
      delegate_mock.should_receive(method)
      actual.send(method)
    end
    rescue 
      result = false
    end
    result
  end

    failure_message_for_should do |actual|
      "it should delegate '#{method}' to '#{@expected_delegate}' but does not" 
    end
  end

