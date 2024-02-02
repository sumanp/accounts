# Use the official Ruby image with the desired version
FROM ruby:3.2.2

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy Gemfile and Gemfile.lock to the container
COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN bundle install

# Copy the application code to the container
COPY . .

# Expose the port the app runs on
EXPOSE 4567

# Command to run the application
CMD ["sh", "-c", "rake db:create && rake db:migrate && rackup --host 0.0.0.0 -p 4567"]
