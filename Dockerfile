FROM seapy/ruby:2.2.0
MAINTAINER Danish Munir <danish@leohealth.com>

RUN apt-get update

# Install nodejs
RUN apt-get install -qq -y nodejs

# Intall software-properties-common for add-apt-repository
RUN apt-get install -qq -y software-properties-common
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes libpq-dev


# Install Nginx.
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN apt-get install -qq -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx
# Add default nginx config
ADD config/nginx.conf /etc/nginx/sites-enabled/default

#(required) Install Rails App
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --without development test
RUN mkdir tmp
RUN mkdir tmp/pids
ADD . /app

# Install foreman
RUN gem install foreman

# Rails App directory
WORKDIR /app

# Add default unicorn config
ADD unicorn.rb /app/config/unicorn.rb

# Add default foreman config
ADD Procfile /app/Procfile

ENV RAILS_ENV production

# Reroute log files for nginx requests and errors
RUN ln -sf /dev/stdout /var/log/access_nginx.log
RUN ln -sf /dev/stderr /var/log/error_nginx.log

#(required) nginx port number
EXPOSE 80

CMD bundle exec rake assets:precompile && foreman start -f Procfile