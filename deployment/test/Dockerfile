# Set the base image to Ubuntu
FROM ruby:2.5.0-stretch

# File Author / Maintainer
MAINTAINER todorus

# Install a javascript runtime
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get update &&\
    apt-get install -y nodejs

# Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - &&\
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update  &&\
    apt-get install -y google-chrome-stable

# Run chrome headlessly
RUN apt-get update &&\
    apt-get install -y xvfb

# Chrome driver
RUN apt-get update &&\
    apt-get -y install unzip
RUN apt-get update &&\
    apt-get -y install chromedriver

# Copy app code
COPY    rails-app   /rails-app

# Install Gems
WORKDIR /rails-app
RUN bundle

# Run tests
CMD bundle exec rake db:migrate && bundle exec rspec spec
