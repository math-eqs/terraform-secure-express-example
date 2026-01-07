# Auth0 Terraform Setup Guide

This guide explains how to automatically create Auth0 applications and retrieve their credentials using Terraform.

## Prerequisites

### 1. Auth0 Account
You need an Auth0 account and tenant (e.g., `your-tenant.auth0.com`)

### 2. Create Management API M2M Application (One-Time Setup)

Before you can use Terraform, you need to create a Machine-to-Machine (M2M) application in Auth0 that Terraform will use to manage resources.

#### Option A: Using Auth0 Dashboard (Recommended for First Time)

1. Go to [Auth0 Dashboard](https://manage.auth0.com/)
2. Navigate to **Applications** → **Applications**
3. Click **Create Application**
4. Name it: `Terraform Provider`
5. Select **Machine to Machine Applications**
6. Choose **Auth0 Management API** as the authorized API
7. **CRITICAL**: Grant the following scopes:
   - `read:clients`
   - `create:clients`
   - `update:clients`
   - `delete:clients`
   - **`read:client_keys`** ⚠️ **REQUIRED to access client_secret**
   - `read:resource_servers`
   - `create:resource_servers`
   - `update:resource_servers`
   - `delete:resource_servers`
   - `read:client_grants`
   - `create:client_grants`
   - `update:client_grants`
   - `delete:client_grants`
8. Click **Authorize**
9. Copy the **Client ID** and **Client Secret** - you'll need these!

#### Option B: Using Auth0 CLI

```bash
# Install Auth0 CLI
npm install -g auth0-cli

# Login
auth0 login

# Create M2M app with required scopes
auth0 apps create \
  --name "Terraform Provider" \
  --type m2m \
  --grants "https://YOUR-TENANT.auth0.com/api/v2/" \
  --scopes "read:clients,create:clients,update:clients,delete:clients,read:client_keys,read:resource_servers,create:resource_servers,update:resource_servers,delete:resource_servers,read:client_grants,create:client_grants,update:client_grants,delete:client_grants"
```

### 3. Install Terraform

```bash
# macOS
brew install terraform

# Or download from
# https://www.terraform.io/downloads
```

## Configuration

### 1. Copy the Example Variables File

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit `terraform.tfvars`

```hcl
# Auth0 Configuration (for Terraform Provider)
# These are the credentials from the M2M app you created above
auth0_domain        = "your-tenant.auth0.com"          # Your Auth0 tenant domain
auth0_client_id     = "YOUR_MANAGEMENT_API_CLIENT_ID"   # From M2M app
auth0_client_secret = "YOUR_MANAGEMENT_API_CLIENT_SECRET" # From M2M app

# Application Configuration
app_name        = "My Express App"
app_environment = "dev"  # or "staging", "prod"

# Callback URLs for your application
allowed_callback_urls = [
  "http://localhost:3000/callback",
  "https://yourdomain.com/callback"
]

allowed_logout_urls = [
  "http://localhost:3000",
  "https://yourdomain.com"
]
```

### 3. Alternative: Use Environment Variables

Instead of `terraform.tfvars`, you can use environment variables:

```bash
export TF_VAR_auth0_domain="your-tenant.auth0.com"
export TF_VAR_auth0_client_id="YOUR_MANAGEMENT_API_CLIENT_ID"
export TF_VAR_auth0_client_secret="YOUR_MANAGEMENT_API_CLIENT_SECRET"
export TF_VAR_app_name="My Express App"
export TF_VAR_app_environment="dev"
```

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

This downloads the Auth0 provider and initializes the workspace.

### 2. Preview Changes

```bash
terraform plan
```

This shows what Terraform will create without actually creating it.

### 3. Create Resources

```bash
terraform apply
```

Type `yes` when prompted. Terraform will:
- Create a new Auth0 application
- Generate `client_id` and `client_secret` automatically
- Create an Auth0 API resource
- Output all credentials

### 4. View Outputs

After applying, view the credentials:

```bash
# View all outputs (non-sensitive only)
terraform output

# View specific output
terraform output auth0_client_id

# View sensitive outputs
terraform output -json | jq '.auth0_client_secret.value' -r

# Get complete configuration in JSON
terraform output -json application_config

# Get ready-to-use Docker command
terraform output -raw docker_run_command
```

## Important Notes

### About `read:client_keys` Scope

⚠️ **CRITICAL**: The `read:client_keys` scope must be granted to your Terraform Management API client, otherwise:
- The `client_secret` output will be an empty string
- Your application won't be able to authenticate
- Terraform will not show an error, but the secret will be missing

### Security Best Practices

1. **Never commit `terraform.tfvars`** to git
   - It contains sensitive credentials
   - Add it to `.gitignore`

2. **Use remote state** for production
   ```hcl
   terraform {
     backend "s3" {
       bucket = "my-terraform-state"
       key    = "auth0/terraform.tfstate"
       region = "us-east-1"
     }
   }
   ```

3. **Protect Terraform state files**
   - They contain client secrets in plain text
   - Never commit `terraform.tfstate` to version control

4. **Use different environments**
   - Set `app_environment = "dev"` for development
   - Set `app_environment = "prod"` for production
   - This creates separate applications

## What Gets Created

When you run `terraform apply`, Terraform creates:

1. **Auth0 Application** (`auth0_client.express_app`)
   - Type: Regular Web Application
   - Auto-generated `client_id`
   - Auto-generated `client_secret`
   - Configured callbacks and logout URLs

2. **Auth0 API** (`auth0_resource_server.express_api`)
   - API identifier for your app
   - Scopes: `read:profile`, `write:profile`

3. **Client Credentials Configuration** (`auth0_client_credentials.express_app`)
   - Authentication method: `client_secret_post`
   - Allows access to the `client_secret`

4. **(Optional) M2M Application** - Only if `app_environment = "prod"`
   - Machine-to-Machine application
   - For backend API access

## Outputs Explained

| Output | Description | Sensitive |
|--------|-------------|-----------|
| `auth0_client_id` | Your application's client ID | No |
| `auth0_client_secret` | Your application's client secret | Yes |
| `auth0_domain` | Your Auth0 tenant domain | No |
| `auth0_api_identifier` | Your API identifier | No |
| `application_config` | Complete environment variables object | Yes |
| `credentials_json` | All credentials in JSON format | Yes |
| `docker_run_command` | Ready-to-use Docker command | Yes |

## Using the Credentials

### In Your Application

Use the output credentials in your Express app:

```javascript
const passport = require('passport');
const Auth0Strategy = require('passport-auth0');

const strategy = new Auth0Strategy(
  {
    domain: process.env.AUTH0_CLIENT_DOMAIN,
    clientID: process.env.AUTH0_CLIENT_ID,
    clientSecret: process.env.AUTH0_CLIENT_SECRET,
    callbackURL: process.env.AUTH0_CALLBACK_URL || 'http://localhost:3000/callback'
  },
  function(accessToken, refreshToken, extraParams, profile, done) {
    return done(null, profile);
  }
);

passport.use(strategy);
```

### With Docker

```bash
# Get the Docker command with credentials
terraform output -raw docker_run_command

# Or manually:
docker run --name terraform-secure-express -p 3000:3000 \
  --env AUTH0_CLIENT_ID=$(terraform output -raw auth0_client_id) \
  --env AUTH0_CLIENT_SECRET=$(terraform output -json | jq -r '.auth0_client_secret.value') \
  --env AUTH0_CLIENT_DOMAIN=$(terraform output -raw auth0_domain) \
  --env AUTH0_API_IDENTIFIER=$(terraform output -raw auth0_api_identifier) \
  terraform-secure-express:1.0
```

### In CI/CD

```bash
# Export credentials as environment variables
export AUTH0_CLIENT_ID=$(terraform output -raw auth0_client_id)
export AUTH0_CLIENT_SECRET=$(terraform output -json | jq -r '.auth0_client_secret.value')
export AUTH0_DOMAIN=$(terraform output -raw auth0_domain)
export AUTH0_API_IDENTIFIER=$(terraform output -raw auth0_api_identifier)
```

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

This will delete the Auth0 application and API. Type `yes` when prompted.

## Troubleshooting

### Problem: `client_secret` is empty

**Solution**: Make sure your Terraform Management API client has the `read:client_keys` scope granted.

### Problem: Permission denied errors

**Solution**: Check that your Terraform Management API client has all required scopes listed in the Prerequisites section.

### Problem: Terraform can't find resources

**Solution**: Run `terraform init` to download the providers.

### Problem: State conflicts

**Solution**: If multiple people are working on this, use a remote backend like S3 or Terraform Cloud.

## Advanced: Client Secret Rotation

See the [official Auth0 guide](https://registry.terraform.io/providers/auth0/auth0/latest/docs/guides/client_secret_rotation) for rotating client secrets with zero downtime.

## Resources

- [Auth0 Terraform Provider Documentation](https://registry.terraform.io/providers/auth0/auth0/latest/docs)
- [Auth0 Management API](https://auth0.com/docs/api/management/v2)
- [Terraform Documentation](https://www.terraform.io/docs)
