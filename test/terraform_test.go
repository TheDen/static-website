package test

import (
	"crypto/tls"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func validate(status int, _ string) bool {
	return status == 200
}

func TestTerraformHelloWorldExample(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	staticWebsite := terraform.Output(t, terraformOptions, "static_website_url")
	tlsConfig := tls.Config{}
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second

	// Check if the CloudFront index.html endpoint returns 200
	http_helper.HttpGetWithRetryWithCustomValidation(t, staticWebsite, &tlsConfig, maxRetries, timeBetweenRetries, validate)
}
