require 'spec_helper'
require 'json'

RSpec.describe LoginController, type: :controller do
  describe 'POST /login' do
    it 'logs in a user without two-factor authentication' do
      user = create_user(email: 'test@example.com', password: 'password')

      post '/login', { email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['success']).to eq(true)
      expect(JSON.parse(last_response.body)['message']).to include('Login successful')

    end

    it 'sends two-factor authentication code for user with two-factor enabled' do
      user = create_user(email: 'test@example.com', password: 'password', two_factor_enabled: true)

      allow(AuthenticationHelpers).to receive(:generate_otp_now).and_return('123456') # Stub the OTP for testing
      allow(AuthMailer).to receive(:send_otp_email)

      post '/login', { email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['success']).to eq(true)
      expect(JSON.parse(last_response.body)['message']).to include('Two-factor authentication code sent')
    end

    it 'handles login failure' do
      post '/login', { email: 'nonexistent@example.com', password: 'wrong_password' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(401)
      expect(JSON.parse(last_response.body)['success']).to eq(false)
      expect(JSON.parse(last_response.body)['message']).to include('Invalid email or password')
    end
  end

  describe 'POST /login/verify_otp/:id' do
    it 'verifies two-factor authentication successfully' do
      user = create_user(email: 'test@example.com', password: 'password', two_factor_enabled: true)
      allow(AuthenticationHelpers).to receive(:verify_otp?).and_return(true) # Stub the OTP verification for testing

      post "/login/verify_otp/#{user.id}", { otp: '123456' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['success']).to eq(true)
      expect(JSON.parse(last_response.body)['message']).to include('Two-factor authentication successful')
    end

    it 'handles incorrect or expired two-factor authentication code' do
      user = create_user(email: 'test@example.com', password: 'password', two_factor_enabled: true)
      allow(AuthenticationHelpers).to receive(:verify_otp?).and_return(false) # Stub the OTP verification for testing

      post "/login/verify_otp/#{user.id}", { otp: '654321' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(401)
      expect(JSON.parse(last_response.body)['success']).to eq(false)
      expect(JSON.parse(last_response.body)['message']).to include('Incorrect or expired two-factor authentication code')
    end
  end

  # Helper method to create a user for testing
  def create_user(email:, password:, two_factor_enabled: false)
    User.create(email: email, password: password, two_factor_enabled: two_factor_enabled)
  end
end
