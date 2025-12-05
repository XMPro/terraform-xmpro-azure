# AAD Container Module

Deploys Azure Container Instance to provision AAD database users.

## Purpose

This module runs a container that:
- Connects to SQL Server using AAD authentication
- Creates database users from external providers (managed identities)
- Grants db_owner permissions to application identities

This must run AFTER databases are created.

## Dependencies

- Requires AAD identities from aad-identities module
- Requires databases from database module
- Must be deployed after SQL Server and databases exist

## Outputs

- Container group ID and name
