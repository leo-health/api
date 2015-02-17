FROM seapy/rails-nginx-unicorn-pro:v1.0-ruby2.2.0-nginx1.6.0
MAINTAINER Danish Munir <danish@leohealth.com>

# Intall software-properties-common for add-apt-repository
RUN apt-get install -qq -y software-properties-common
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes libpq-dev


# Add default nginx config
ADD config/nginx.conf /etc/nginx/sites-enabled/default
# ADD unicorn.rb config/unicorn.rb

#(required) Install Rails App
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
# Add default unicorn config
ADD unicorn.rb /app/config/unicorn.rb

# Add default foreman config
ADD Procfile /app/Procfile

RUN mkdir -p /tmp/pids

# Reroute log files for nginx requests and errors
RUN ln -sf /dev/stdout /var/log/access_nginx.log
RUN ln -sf /dev/stderr /var/log/error_nginx.log

RUN bundle install --without development test
ADD . /app
# Rails App directory
WORKDIR /app
ENV RAILS_ENV production

#(required) nginx port number
EXPOSE 80

CMD bundle exec rake assets:precompile && foreman start -f Procfile