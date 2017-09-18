Puppet::Type.newtype(:vpp_config) do

  ensurable

  newparam(:setting, :namevar => true) do
  end

  newproperty(:value) do
    munge do |value|
      value.to_s.strip
    end
  end

end
