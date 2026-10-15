locals {
  # Maximum temporary (local) storage per instance class for Aurora PostgreSQL, in GiB.
  # Source: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Managing.html
  # ("Temporary storage limits for Aurora PostgreSQL"). Other engines: pass local_storage_gib.
  local_storage_gib = {
    "db.x2g.16xlarge" = 1829, "db.x2g.12xlarge" = 1606, "db.x2g.8xlarge" = 1071, "db.x2g.4xlarge" = 535
    "db.x2g.2xlarge"  = 268, "db.x2g.xlarge" = 134, "db.x2g.large" = 67

    "db.r8g.48xlarge" = 3072, "db.r8g.24xlarge" = 1536, "db.r8g.16xlarge" = 998, "db.r8g.12xlarge" = 749
    "db.r8g.8xlarge"  = 499, "db.r8g.4xlarge" = 250, "db.r8g.2xlarge" = 125, "db.r8g.xlarge" = 63, "db.r8g.large" = 31

    "db.r7g.16xlarge" = 1008, "db.r7g.12xlarge" = 756, "db.r7g.8xlarge" = 504, "db.r7g.4xlarge" = 252
    "db.r7g.2xlarge"  = 126, "db.r7g.xlarge" = 63, "db.r7g.large" = 32

    "db.r7i.48xlarge" = 3072, "db.r7i.24xlarge" = 1500, "db.r7i.16xlarge" = 1008, "db.r7i.12xlarge" = 748
    "db.r7i.8xlarge"  = 504, "db.r7i.4xlarge" = 249, "db.r7i.2xlarge" = 124, "db.r7i.xlarge" = 62, "db.r7i.large" = 31

    "db.r6g.16xlarge" = 1008, "db.r6g.12xlarge" = 756, "db.r6g.8xlarge" = 504, "db.r6g.4xlarge" = 252
    "db.r6g.2xlarge"  = 126, "db.r6g.xlarge" = 63, "db.r6g.large" = 32

    "db.r6i.32xlarge" = 1829, "db.r6i.24xlarge" = 1500, "db.r6i.16xlarge" = 1008, "db.r6i.12xlarge" = 748
    "db.r6i.8xlarge"  = 504, "db.r6i.4xlarge" = 249, "db.r6i.2xlarge" = 124, "db.r6i.xlarge" = 62, "db.r6i.large" = 31

    "db.r5.24xlarge" = 1500, "db.r5.16xlarge" = 1008, "db.r5.12xlarge" = 748, "db.r5.8xlarge" = 504
    "db.r5.4xlarge"  = 249, "db.r5.2xlarge" = 124, "db.r5.xlarge" = 62, "db.r5.large" = 31

    "db.r4.16xlarge" = 960, "db.r4.8xlarge" = 480, "db.r4.4xlarge" = 240, "db.r4.2xlarge" = 120
    "db.r4.xlarge"   = 60, "db.r4.large" = 30

    "db.t4g.large" = 16.5, "db.t4g.medium" = 8.13, "db.t3.large" = 16, "db.t3.medium" = 7.5
  }
}
