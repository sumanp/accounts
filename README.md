## Task: Development of Two-Factor Authentication Service

**Description:**
Your task is to develop a two-factor authentication service that provides an additional layer of security for users. The service should include registration, login with two-factor authentication, and account settings management.

## Requirements

**Registration:**
- Users should be able to create a new account by providing their email and password.
- Passwords should be encrypted and stored securely.
- After successful registration, a confirmation email should be sent to the provided email address.

**Login:**
- After registration, users should be able to log in by providing their email and password.
- Two-factor authentication should be implemented using one-time codes (e.g., through SMS, authenticator app, or email).
- Users should enter the correct one-time code to successfully log in.

**Account Settings Management:**

- Users should be able to change their passwords.
- Users should be able to enable or disable two-factor authentication.
- When enabling two-factor authentication, users should be provided with a secret key (e.g., a QR code) to set up their authenticator app.

**Error Handling and Security:**

- Handle possible errors during registration, login, and account settings management, providing informative error messages.
- Follow secure practices and standards when storing and handling passwords and secret keys.

**Conditions:**
- Use Ruby for development.
- Use PostgreSQL as the database for storing user data.
- Provide the source code of your project in an archive or through version control system (e.g., Git).

**Evaluation:**
Your solution will be evaluated based on the following criteria:
- Code quality, including structure, cleanliness, and readability.
- Correctness and completeness of the implemented requirements.
- Effective utilization of Ruby programming language.
- Proper handling of errors and adherence to security best practices.
- Please note that this is a general outline, and you are encouraged to provide additional details or specifications as needed for the task. Good luck with the assignment!


Note: 
1. We need you to containerize your main application along with all dependent services, including databases, coordinating everything through a single Docker Compose file. This approach is essential for consistency across
different environments and will allow efficient management of multi-container Docker applications. Please ensure that each service is defined as a separate container, with proper communication links, persistent storage for databases, and secure handling of sensitive information through environment variables. If
you have any questions or need clarification, feel free to reach out.**

2. Please add all the information about the assignment in the Readme.**


## Usage Instruction
**Initialise Application & Run tests:**

    docker-compose up --build
    
This is to orchestrate web, db & test containers. The test container will run rspec.
The endpoints are written in ruby on Sinatra framework. Rspec is used for testing.

Note: Ideally the smtp credentails should not be hard-coded on the docker-compose file. This is done in this case to make it easier for the reviewer to test emails. The credentails are temporary.

**Endpoints**

    post '/register', { email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'
    post '/login', { email: 'test@example.com', password: 'password' }.to_json, 'CONTENT_TYPE' => 'application/json'
    post "/login/verify_otp/#{user.id}", { otp: '123456' }.to_json, 'CONTENT_TYPE' => 'application/json'
    put '/settings/enable_otp/3', {}.to_json, 'CONTENT_TYPE' => 'application/json' # user_id = 3
    put '/settings/disable_otp/3', {}.to_json, 'CONTENT_TYPE' => 'application/json' # user_id = 3
    put '/settings/change_password/1', { current_password: 'password', new_password: 'new_password' }.to_json, 'CONTENT_TYPE' => 'application/json'

**Security**
1. Bcrypt is used for securely hashing and storing the password in the db.
2. ROTP is used for generating time based one-time password. We are using a proven library to reduce the security risk that can possibly raise due to reinventing the wheel or writing a TOPT algorithm.
3. Sinatra comes with built-in security features through Rack Protection. Rack Protection has been enabled to prevent common attacks.
4. ActiveRecord's has_secure_password is used to securely hash and store the password in the db. This is due to time constraint and avoid security flaws.


**Possible Improvements**
1. Use token-based authentication (e.g., JWT) to secure API endpoints. Authenticate and authorize users before allowing access to sensitive resources. This was skipped due to time constraint.
2. Rate limiting could be implemented to circumvent Denial-of-Service attack.
3. Proper logging & instrumentation can be implemented for monitoring.
4. Emails can be moved to a background job.
5. Register endpoint can have token confirmation via email.
6. Backup otp code can be implemented.


    
    
