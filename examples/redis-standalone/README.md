# Standalone Redis Cache Deployment

This example deploys a standalone Azure Redis Cache that can be shared across multiple XMPro deployments.

## Benefits

- **One-time provisioning**: Deploy Redis once (15-20 minutes), reuse many times
- **Faster main deployments**: Main XMPro infrastructure deploys in 5-10 minutes instead of 20-30
- **Cost-effective**: No repeated provisioning time and resource churn
- **Data persistence**: Redis data persists between XMPro redeployments
- **Shared caching**: Multiple environments can share the same Redis instance

## Usage

### Step 1: Deploy Redis Cache

```bash
# Navigate to redis-standalone directory
cd examples/redis-standalone

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy Redis (this will take 15-20 minutes)
terraform apply

# Save the connection string
export REDIS_CONN=$(terraform output -raw redis_connection_string)
```

### Step 2: Use in Main XMPro Deployment

```bash
# Navigate to your main deployment
cd ../basic  # or ../dev

# Option A: Use environment variable
export TF_VAR_redis_connection_string="$REDIS_CONN"

# Option B: Add to terraform.tfvars
echo "redis_connection_string = \"$REDIS_CONN\"" >> terraform.tfvars

# Configure to use existing Redis
cat >> terraform.tfvars <<EOF
enable_auto_scale = true
create_redis_cache = false  # Don't create new Redis
EOF

# Deploy XMPro (now takes only 5-10 minutes)
terraform apply
```

## Configuration Options

### Redis SKU Sizes

| Capacity | Size | Memory | Connections | Bandwidth |
|----------|------|--------|-------------|-----------|
| 0 | C0 | 250 MB | 256 | Low |
| 1 | C1 | 1 GB | 1,000 | Low-Medium |
| 2 | C2 | 2.5 GB | 2,000 | Medium |
| 3 | C3 | 6 GB | 5,000 | Medium |
| 4 | C4 | 13 GB | 10,000 | Medium-High |
| 5 | C5 | 26 GB | 15,000 | High |
| 6 | C6 | 53 GB | 20,000 | Highest |

### Premium Features (Optional)

For production workloads, consider Premium tier:

```hcl
redis_family   = "P"
redis_sku_name = "Premium"
redis_capacity = 1  # P1 = 6GB, P2 = 13GB, P3 = 26GB, P4 = 53GB
```

Premium tier provides:
- Redis data persistence
- Redis cluster support
- Virtual network support
- Geo-replication
- Higher throughput

## Multiple Environments

You can create different Redis instances for different environments:

```bash
# Development Redis
terraform workspace new dev
terraform apply -var="environment=dev" -var="prefix=xmpro-dev"

# Production Redis
terraform workspace new prod
terraform apply -var="environment=prod" -var="prefix=xmpro-prod" \
  -var="redis_sku_name=Premium" -var="redis_family=P" -var="redis_capacity=1"
```

## Cleanup

To destroy the Redis cache when no longer needed:

```bash
terraform destroy
```

**Warning**: This will delete the Redis cache and all cached data. Ensure no XMPro deployments are using it before destroying.

## Cost Optimization

- Use Basic tier for development/testing
- Use Standard tier for staging/UAT
- Use Premium tier for production
- Consider sharing Redis across non-production environments
- Monitor usage and scale as needed

## Monitoring

After deployment, monitor your Redis cache:

```bash
# Get Redis metrics
az redis show --name <redis-name> --resource-group <rg-name>

# View cache usage
az monitor metrics list --resource <redis-id> --metric "used_memory"
```