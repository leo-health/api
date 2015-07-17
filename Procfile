web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
nginx: /usr/sbin/nginx -c /etc/nginx/nginx.conf
worker: bundle exec rake jobs:work
