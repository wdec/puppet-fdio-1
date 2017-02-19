Puppet::Type.newtype(:vpp_config) do

  ensurable

  newparam(:setting, :namevar => true) do
  end

  newproperty(:value) do
    munge do |value|
      value.strip if value.is_a? String
    end
  end

end
