# AAD Identities Module

Creates Azure AD managed identities for SQL Server AAD authentication.

## Purpose

This module creates the managed identities needed for:
- SQL Server AAD administrator
- App Service database authentication (SM, AD, DS)

These identities must be created before the SQL Server so they can be assigned as AAD administrators.

## Outputs

- AAD SQL users identity (for SQL Server admin)
- SM, AD, DS app identities (for database access)
