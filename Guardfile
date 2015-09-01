guard :bundler do
  watch('Gemfile')
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { 'spec' }
  watch('spec/rails_helper.rb') { 'spec' }
  watch(%r{spec/factories(/.+)\.rb})  { 'spec' }

  watch(%r{^bin/(.+)(\.rb)?$}) { |m| "spec/bin/#{m[1]}_spec.rb" }
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml|\.slim)$}) do |m|
    "spec/#{m[1]}#{m[2]}_spec.rb"
  end
  watch(%r{^app/controllers/(.+)_(controller)\.rb$}) do |m|
    [
      "spec/routing/#{m[1]}_routing_spec.rb",
      "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb",
      "spec/acceptance/#{m[1]}_spec.rb"
    ]
  end
  watch(%r{^spec/support/(.+)\.rb$})                  { 'spec' }
  watch('config/routes.rb')                           { 'spec/routing' }
  watch('app/controllers/application_controller.rb')  { 'spec/controllers' }
end

guard :rubocop, cli: '-R -D' do
  watch(/(Gemfile|Guardfile|Rakefile)$/)
  watch(/.+\.rb$/)
  watch(/.+\.rake$/)
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end

guard 'brakeman', run_on_start: true, quiet: true do
  watch(%r{^app/.+\.(erb|rb)$})
  watch(%r{^config/.+\.rb$})
  watch(%r{^lib/.+\.rb$})
  watch('Gemfile')
end

guard 'unicorn', daemonized: true, config_file: 'config/dev_unicorn.rb' do
  watch('Gemfile.lock')
  watch(%r{^config/.+\.rb$})
end
