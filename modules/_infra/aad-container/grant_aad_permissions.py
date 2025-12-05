#!/usr/bin/env python3
"""
Azure AD SQL Database User Creation Script

This script creates Azure AD-authenticated database users for managed identities
and grants them db_owner permissions. It supports custom database names through
the DATABASES_CONFIG environment variable.

Environment Variables Required:
- SQL_SERVER: Fully qualified SQL Server name (e.g., server.database.windows.net)
- CLIENT_ID: Client ID of the managed identity used for authentication
- DATABASES_CONFIG: JSON array of [database_name, user_identity_name] pairs
  Example: [["SM", "mi-company-sm-db-suffix"], ["AD", "mi-company-ad-db-suffix"]]
"""

import pyodbc
import os
import time
import struct
import json
from azure.identity import ManagedIdentityCredential

def main():
    # Load configuration from environment variables
    server = os.environ['SQL_SERVER']
    client_id = os.environ['CLIENT_ID']

    # Parse database configuration from environment variable
    # Format: [["db_name1", "user1"], ["db_name2", "user2"], ...]
    databases_config_json = os.environ.get('DATABASES_CONFIG', '[]')
    databases = json.loads(databases_config_json)

    print(f"Database configuration loaded: {len(databases)} databases")
    for db_name, user_name in databases:
        if user_name:
            print(f"  - {db_name} → {user_name}")
        else:
            print(f"  - {db_name} → (no user assigned, will skip)")

    # Filter out databases without assigned users
    databases = [(db_name, user_name) for db_name, user_name in databases if user_name]

    if not databases:
        print("ERROR: No databases configured with users. Check DATABASES_CONFIG environment variable.")
        exit(1)

    # Get access token using Azure Identity library
    print("\nAcquiring access token using managed identity...")
    credential = ManagedIdentityCredential(client_id=client_id)
    token = credential.get_token("https://database.windows.net/.default")
    token_bytes = token.token.encode("UTF-16-LE")
    token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)

    # Connection string using access token
    # SQL_COPT_SS_ACCESS_TOKEN = 1256
    connection_string = f"Driver={{ODBC Driver 17 for SQL Server}};Server=tcp:{server},1433;Encrypt=yes;TrustServerCertificate=no;"

    print("\nWaiting for managed identity to propagate...")
    time.sleep(30)

    # Process each database
    for db_name, db_user in databases:
        print(f"\nCreating database user for {db_name} database: {db_user}")
        conn_str = connection_string + f"Database={db_name};"

        try:
            # Connect using access token (SQL_COPT_SS_ACCESS_TOKEN = 1256)
            with pyodbc.connect(conn_str, attrs_before={1256: token_struct}) as conn:
                cursor = conn.cursor()

                # Check if user already exists
                cursor.execute(f"SELECT COUNT(*) FROM sys.database_principals WHERE name = '{db_user}'")
                exists = cursor.fetchone()[0]

                if exists:
                    print(f"  User {db_user} already exists, skipping creation")
                else:
                    # Create user from Azure AD external provider
                    sql = f"CREATE USER [{db_user}] FROM EXTERNAL PROVIDER;"
                    cursor.execute(sql)
                    conn.commit()
                    print(f"  Created user {db_user}")

                    # Grant db_owner role
                    sql = f"ALTER ROLE db_owner ADD MEMBER [{db_user}];"
                    cursor.execute(sql)
                    conn.commit()
                    print(f"  Granted db_owner role to {db_user}")

                print(f"  ✓ Successfully configured {db_user} for {db_name} database")
        except Exception as e:
            print(f"  ✗ ERROR processing {db_name} database: {e}")
            raise

    print("\n✓ All database users configured successfully!")

if __name__ == "__main__":
    main()
