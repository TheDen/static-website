# Static S3 Website

- [Static S3 Website](#static-s3-website)
  * [Overview](#overview)
  * [Assumptions/Considerations](#assumptionsconsiderations)
- [Setup](#setup)
  * [Terraform](#terraform)
  * [Deploy](#deploy)
- [Test](#test)
- [Improvements, potential solutions, etc.](#improvements-potential-solutions-etc)

## Overview 

Terraform to create an s3 bucket `theden-static-website` with the default_root_object `index.html` (as defined in `bucket_data/index.html, and a CloudFront distribution with the bucket as its origin.

## Assumptions/Considerations

* Scoped for a simple development environment, within AWS free tier usage, hence
  * No custom additional `CNAME` for the CloudFront distribution
  * Logging disabled for CloudFront
  * Default S3 config for encryption, lifecycles, logging, and versioning (mostly `none`)
* Configured to default to the `ap-southeast-2` AWS region
* `CachingOptimized` for the S3 origin (as recommended by AWS
* Georestricted to `Australia`
* Assumes the `default` AWS profile is set


# Setup


## Terraform

Initialise the working directory

```shell
Terraform init
```

## Deploy

```shell
Terraform plan
```

```shell
Terraform apply
```

To see the output values, e.g.,

```shell
terraform output
cloudfront_etag = "E3Q70LPF8BDW12"
s3_bucket_arn = "arn:aws:s3:::theden-static-website"
s3_bucket_id = "theden-static-website"
static_website_url = "https://d3w1hji9oouxbr.cloudfront.net"
```

# Test

The [Terratest](https://github.com/gruntwork-io/terratest/) library is used to test the terraform deployment and check if the CloudFront index.html endpoint returns 200

To pull in the dependencies

```shell
cd test
go mod init "github.com/static-website"
go mod tidy
```

To run the tests, in the `test` folder run

```shell
go test
```

# Improvements, potential solutions, etc.

Potential improvements
 
* Set up different environments with terraform, using terraform workspaces 
* Manage the terraform state in S3 or elsewhere
* `terraform plan` and `apply` via CI, and show diff in PR comments
* Add more linters and static analysis tools in the CI, e.g., [tfsec](https://github.com/aquasecurity/tfsec)
* add a `Makefile` for the go code (and potentially terraform)
* Invalidate CloudFront cache (or specific path) on changes to the bucket data 
* Add a `CODEOWNERS` file

Alternative solutions

* Use buckets on Google Cloud, with Cloud DNS
* Simplest solution would be to use GitHub pages to with a `gh-pages` branch for deployment, though you lose configurability wrt the CDN
* Use AWS Amplify
* Could use CloudFormation instead of terraform to build the infra
* If a Kubernetes cluster already exists, with something like `ingress-nginx`

Productionising

* Use Route53 as a `CNAME` for CloudFront, and use `ACM`
* Set up different environments
* Configure CloudFront response header policy for what's required
* Add encryption to buckets, and potentially versioning
* Minify the static files prior to uploading to the bucket 





