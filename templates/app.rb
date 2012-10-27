PIN0.output!

loop do
  PIN0.value = 1
  sleep 0.5
  PIN0.value = 0
  sleep 0.5
end
