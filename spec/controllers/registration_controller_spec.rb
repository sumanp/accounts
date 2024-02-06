require 'spec_helper'

RSpec.describe RegistrationController, type: :controller do
  describe 'POST /register' do
    it 'registers a new user and sends a confirmation email' do
      allow(User).to receive(:valid?).and_return(true)

      # Stubbing the save method to return true for successful save
      allow_any_instance_of(User).to receive(:save).and_return(true)

      # Stubbing the send_confirmation_email method
      allow(AuthMailer).to receive(:send_confirmation_email)

      post '/register', { email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Registration successful')

    end

    it 'handles registration failure' do
      allow(User).to receive(:valid?).and_return(false)

      post '/register', { email: 'test@example.com' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to include('Validation failed')
    end

    it 'handles email already registered' do
      allow(User).to receive(:valid?).and_return(true)
      # Stubbing find_by to simulate an existing user with the same email
      allow(User).to receive(:find_by).with(email: 'test@example.com').and_return(User.new)

      post '/register', { email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to include('Email already registered')
    end
  end
end
