require 'spec_helper'

describe 'Registration API' do
  context 'when registering a new user' do
    it 'creates a new user and returns a success message' do
      post '/register', { email: 'test@example.com', password: 'password' }.to_json
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to include('message' => 'Registration successful. Confirmation email sent.')
    end

    it 'returns an error if registration fails' do
      allow_any_instance_of(User).to receive(:save).and_return(false)
      post '/register', { email: 'test@example.com', password: 'password' }.to_json
      expect(last_response.status).to eq(422)
      expect(JSON.parse(last_response.body)).to include('error' => 'Error during registration. Please try again.')
    end
  end
end