## Task: Development of Two-Factor Authentication Service

  

## Usage Instruction

**Initialise Application & Run tests:**

  

`docker-compose up --build`

This is to orchestrate web, db & test containers. The test container will run rspec.

The endpoints are written in ruby on Sinatra framework. Rspec is used for testing.

  

*Note: Ideally the SMTP credentials should not be hard-coded on the docker-compose file. This is done in this case to make it easier for the reviewer to test emails. The credentials are temporary.*

  

**Endpoints**


Additionally, postman collection `arival.postman_collection.json` has been added for the reviewer's convenience when testing API endpoints.

  

Please test API endpoints in this sequence:

1. Register (check email for confirmation)
`post '/register', { email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'`

    
2. Login
`post '/login', { email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'`

3. Enable 2FA (pass user_id from login response)
`put '/settings/enable_otp/1', {}.to_json, 'CONTENT_TYPE' => 'application/json' # user_id = 3`

4. Login
`post '/login', { email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'`

5. Verify OTP: Enter the OTP received on Email (pass user_id from login response)
`post "/login/verify_otp/#{user.id}", { otp: '123456' }.to_json, 'CONTENT_TYPE' => 'application/json'`

6. Disable 2FA (pass user_id from login response)
`put '/settings/disable_otp/1', {}.to_json, 'CONTENT_TYPE' => 'application/json' # user_id = 3`

7. Login to verify
`post '/login', { email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'`

8. Change Password (pass user_id from login response)
`put '/settings/change_password/1', { current_password: 'password', new_password: 'new_password' }.to_json, 'CONTENT_TYPE' => 'application/json'`

  

**Security**

1. Bcrypt is used for securely hashing and storing the password in the db.

2. ROTP is used for generating time based one-time password. We are using a proven library to reduce the security risk that can possibly raise due to reinventing the wheel or writing a TOPT algorithm.

3. Sinatra comes with built-in security features through Rack Protection. Rack Protection has been enabled to prevent common attacks.

4. ActiveRecord's has_secure_password is used to securely hash and store the password in the db. This is due to time constraint and avoid security flaws.

  
  

**Possible Improvements**

1. Use token-based authentication (e.g., JWT) to secure API endpoints. Authenticate and authorize users before allowing access to sensitive resources. This was skipped due to time constraints.

2. Rate limiting could be implemented to circumvent Denial-of-Service attacks.

3. Proper logging & instrumentation can be implemented for monitoring.

4. Emails can be moved to a background job.

5. Register endpoint can have token confirmation via email.

6. Backup OTP code can be implemented.
