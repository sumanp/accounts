require 'spec_helper'
require 'json'

RSpec.describe SettingsController, type: :controller do
  describe 'PUT /settings/change_password/:id' do
    it 'changes user password successfully' do
      user = create_user(id: 1)

      put '/settings/change_password/1', { current_password: 'password', new_password: 'new_password' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['success']).to eq(true)
      expect(JSON.parse(last_response.body)['message']).to include('Password updated successfully')
    end

    it 'handles invalid current password' do
      user = create_user(id: 2, current_password: 'wrong_password', new_password: 'new_password')

      put '/settings/change_password/2', { current_password: 'wrong_password', new_password: 'new_password' }.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(401)
      expect(JSON.parse(last_response.body)['success']).to eq(false)
      expect(JSON.parse(last_response.body)['message']).to include('Invalid current password or user_id.')
    end
  end

  describe 'PUT /settings/enable_otp/:id' do
    it 'enables two-factor authentication successfully' do
      user = create_user(id: 3, two_factor_enabled: false)

      allow(AuthenticationHelpers).to receive(:generate_otp_secret).and_return('otp_secret')
      allow(AuthenticationHelpers).to receive(:generate_otp_uri).and_return('otp_uri')

      put '/settings/enable_otp/3', {}.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['success']).to eq(true)
      expect(JSON.parse(last_response.body)['message']).to include('Two-factor authentication enabled')
    end

    it 'handles two-factor authentication already enabled' do
      user = create_user(id: 4, two_factor_enabled: true)

      put '/settings/enable_otp/4', {}.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['success']).to eq(false)
      expect(JSON.parse(last_response.body)['message']).to include('Two-factor authentication is already enabled')
    end
  end

  describe 'PUT /settings/disable_otp/:id' do
    it 'disables two-factor authentication successfully' do
      user = create_user(id: 5, two_factor_enabled: true)

      put '/settings/disable_otp/5', {}.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['success']).to eq(true)
      expect(JSON.parse(last_response.body)['message']).to include('Two-factor authentication disabled')
    end

    it 'handles two-factor authentication already disabled' do
      user = create_user(id: 6, two_factor_enabled: false)

      put '/settings/disable_otp/6', {}.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['success']).to eq(false)
      expect(JSON.parse(last_response.body)['message']).to include('Two-factor authentication is already disabled')
    end
  end

  # Helper method to create a user for testing
  def create_user(id:, current_password: nil, new_password: nil, two_factor_enabled: false)
    user = User.create(id: id, email: "user#{id}@example.com", password: 'password', two_factor_enabled: two_factor_enabled)
    user.update(password: new_password) if current_password && new_password
    user
  end
end
