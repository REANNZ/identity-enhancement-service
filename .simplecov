require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

SimpleCov.start('rails') do
  minimum_coverage 100
end
