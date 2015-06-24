RSpec.shared_context 'method', :method do
  let :arguments do metadata[:arguments] end

  let :instance do described_class.new *new_instance_arguments end

  let :metadata do |example| example.metadata end

  let :method do
    proc { |argument| instance.send *send_arguments, &argument }
  end

  let :method_name do |example|
    example.full_description.slice %r{(?:\.|#)(\w+\??)}, 1
  end

  let :new_instance_arguments do
    return [] unless defined? instance_arguments

    instance_arguments
  end

  let :send_arguments do
    [method_name, arguments].compact
  end

  subject {
    if metadata[:procedural]
      instance
    elsif metadata[:exception]
      method
    else
      method.call
    end
  }

  after :example do
    method.call if metadata[:procedural]
  end
end
