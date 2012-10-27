PIN0.output!

loop do
  PIN0.value = 1
  sleep 1
  PIN0.value = 0
  sleep 0
end
