# guacamole-oidc

This image extends `guacamole/guacamole` and enables OpenID Connect.

If you cannot log in with `guacadmin`, the usual cause is that only OpenID auth
is active and no JDBC authentication backend/database schema has been loaded.

## What this template now includes

- OpenID extension (`guacamole-auth-sso-openid`)
- JDBC auth extensions for:
  - MySQL
  - PostgreSQL
  - SQL Server

This allows both:

- OpenID SSO login
- Local username/password login backed by a database (`guacadmin` included)

## Enable local DB auth + OpenID together

The example below uses PostgreSQL. MySQL and SQL Server work similarly.

### 1) Build the image

```bash
docker build --build-arg GUAC_VERSION=1.6.0 -t guacamole-oidc:local .
```

### 2) Create JDBC schema SQL (includes default `guacadmin` user)

```bash
docker run --rm --entrypoint /opt/guacamole/bin/initdb.sh guacamole-oidc:local --postgresql > initdb.sql
```

### 3) Start PostgreSQL and import schema

```bash
docker run -d \
  --name guac-postgres \
  -e POSTGRES_DB=guacamole_db \
  -e POSTGRES_USER=guacamole_user \
  -e POSTGRES_PASSWORD=guacamole_pass \
  -p 5432:5432 \
  postgres:16

cat initdb.sql | docker exec -i guac-postgres psql -U guacamole_user -d guacamole_db
```

### 4) Run Guacamole with both auth methods enabled

```bash
docker run -d \
  --name guacamole \
  --link guac-postgres \
  -p 8080:8080 \
  -e ENABLE_ENVIRONMENT_PROPERTIES=true \
  -e POSTGRESQL_HOSTNAME=guac-postgres \
  -e POSTGRESQL_DATABASE=guacamole_db \
  -e POSTGRESQL_USER=guacamole_user \
  -e POSTGRESQL_PASSWORD=guacamole_pass \
  -e POSTGRESQL_AUTO_CREATE_ACCOUNTS=true \
  -e OPENID_AUTHORIZATION_ENDPOINT=https://idp.example.com/oauth2/v1/authorize \
  -e OPENID_JWKS_ENDPOINT=https://idp.example.com/oauth2/v1/keys \
  -e OPENID_ISSUER=https://idp.example.com \
  -e OPENID_CLIENT_ID=guacamole \
  -e OPENID_CLIENT_SECRET=replace-me \
  -e OPENID_REDIRECT_URI=https://guac.example.com/guacamole \
  -e OPENID_USERNAME_CLAIM_TYPE=preferred_username \
  guacamole-oidc:local
```

## Why this fixes your login issue

- `guacadmin` only exists in the JDBC database schema, not in OpenID itself.
- With JDBC enabled and schema imported, local auth works (`guacadmin/guacadmin`).
- With `POSTGRESQL_AUTO_CREATE_ACCOUNTS=true`, OpenID users are created on first login.

## Quick validation checklist

- Confirm your redirect URI is exactly your Guacamole URL path (`.../guacamole`).
- Confirm JDBC env vars point to a reachable DB host.
- Confirm schema was imported (especially `001-create-schema.sql` and `002-create-admin-user.sql`).
- Confirm `OPENID_USERNAME_CLAIM_TYPE` matches a claim your IdP actually returns.
- Change the `guacadmin` password immediately after first local login.
