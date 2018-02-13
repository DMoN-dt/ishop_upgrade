# ================================
# PROJECT'S GENERAL SITE SECRETS #
# ================================

GOOGLE_RECAPTCHA_API_KEY_PUB = '6LcHiCYUAAAA'
GOOGLE_RECAPTCHA_API_KEY_SECRET = '6LcHiCYU'

JWT_OAUTH_TOKEN_ISSUER = 'some_issuer'
JWT_OAUTH_TOKEN_SECRET = 'some_secret' # cross auth <-> services secret
JWT_OAUTH_TOKEN_API_APPNAME = 'api' # uses in JWT_OAUTH_TOKEN_APPCLIENT_NAME

# DEPRECATED:
OWN_OAUTH2_TOKEN_SECRET = JWT_OAUTH_TOKEN_SECRET
#------------

## ====================================================================
## ============= SEED and SALT must be unique per project =============
PROJECT_USER_EMAIL_HASH_SEED = 0x12345678 # cross auth <-> services secret
