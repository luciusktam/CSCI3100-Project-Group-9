web: bundle exec puma -t 5:5 -p ${PORT:-5000} -e ${RACK_ENV:-production}
worker: bundle exec rails solid_queue:start
release: bundle exec rails db:prepare
