group :red_green_refactor, halt_on_fail: true do
  guard :rubocop, cmd: 'bundle exec rubocop' do
    watch %r{.+\.rb$}
    watch %r{(?:.+/)?\.rubocop.yml$} do |match| File.dirname match.first end
  end

  guard :rspec, cmd: 'bundle exec rspec', all_on_start: true,
                all_after_pass: true do
    watch %r{^((?:libraries|recipes)/(?:.+)).rb$} do |match|
      "spec/unit/#{ match[1] }_spec.rb"
    end
    watch %r{^spec/(.+)_spec\.rb$}
    watch %r{^spec/(?:spec_helper.rb|support/(?:.+)\.rb)$} do 'spec/unit' end
  end
end
