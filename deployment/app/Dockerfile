# Set the base image to Ubuntu
FROM ruby:2.5.0-stretch

# File Author / Maintainer
MAINTAINER todorus

# Update the sources list
RUN apt-get update

# Install a javascript runtime
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs

# Copy app code
COPY    rails-app   /rails-app

# Install Gems
WORKDIR /rails-app
RUN bundle

# Run server
CMD rake db:migrate && rails s
