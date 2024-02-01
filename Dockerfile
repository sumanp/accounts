FROM ruby:3.2.2

# Set the working directory in the container
WORKDIR /usr/src/app

# Install dependencies
RUN gem install bundler
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the application code to the container
COPY . .

# Expose port 4567
EXPOSE 4567

# Start the Sinatra application
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
