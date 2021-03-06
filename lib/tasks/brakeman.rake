desc "Run brakeman to check for any potential vulnerabilities"

task brakeman: :environment do
  sh <<~EOSHELL
    mkdir -p tmp && \
    (brakeman --no-progress -5 --quiet --color --output tmp/brakeman.out --exit-on-warn && \
    echo "No warnings or errors") || \
    (cat tmp/brakeman.out; exit 1)
  EOSHELL
end

if %w[development test].include? Rails.env
  task(:default).prerequisites << :brakeman
end
