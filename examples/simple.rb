# run this as root using the rupi command

PIN8.input!
PIN0.output!

PIN8.up do |value|
  PIN0.value = true
end

PIN8.down do |value|
  PIN0.value = false
end
