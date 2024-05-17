# terraform-aws-dax
# Sample way of calling this module

```
module "dax" {
  version = "0.0.1"
  iam_role_arn = "iam_arn"
  name = "dax-cluster-name"
  node_count = 1
  node_type = "dax.t2.small"
  subnet_ids = [sub-xxxx]
}
```