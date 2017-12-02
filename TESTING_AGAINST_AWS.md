# Testing Against AWS - Integration Testing

## General Approach

In general, we use Terraform to setup test objects in AWS, then run a predefined set of InSpec controls against it (which should all pass); finally we tear down the the environment using Terraform.

We also use the AWS CLI credentials system to manage credentials.

### Installing Terraform

Download [Terraform](https://www.terraform.io/downloads.html).  We currently require at least v0.10 . You may also consider using [tfenv](https://github.com/kamatama41/tfenv), which allows you to install and choose from multiple versions.

### Installing AWS CLI

Install the [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html). We will store profiles for testing in the `~/.aws/credentials` file.

## Limitations

There are some things that we can't (or very much shouldn't) do via Terraform - like manipulating the root account MFA settings.

Also, there are some singleton resources (such as the default VPC, or Config status) that we should not manipulate without consequences.

## Current Solution

We create two AWS accounts, each dedicated to the task of integration testing inspec-aws.  Both accounts will be manually configured (to cover the gap between what we want to examine, and what test fixtures Terraform can set up).  Between the two of them, we want to have a positive and a negative compliance check for each test point.

Put another way, we want a less secure account, against which we will run a profile expecting it to be less secure.  If the profile passes, we have verified that inspec-aws is able to detect the "negative" case.  We call this secondary account - in which we only run tests that we could not fixture or run in the main account - the "minimal" account.

The "default" account's tests cover a superset of the "negative" account's tests.  For example, they both check root account MFA settings, but the default test account will have it enabled (and the inspec tests will expect that) whereas the minimal account will have root MFA disabled (and the corresponding inspec tests will expect that, as well).

All tests (and test fixtures) that do not require such special handling are placed in the "default" set.  That includes both positive and negative checks.

Note that some tests will fail for the first day or two after you set up the accounts, due to the tests checking properties such as the last usage time of an access key, for example.  

Additionally, the first time you run the tests, you will need to accept the user agreement in the AWS marketplace for the linux AMIs we use.  You'll need to do it 4 times, once for each of debian and centos on the two accounts.

### Creating the Default account

1. Create an AWS account.  Make a note of the account email and root password in a secure secret storage system.
2. Create an IAM user named `test-fixture-maker`.
  * Enable programmatic access (to generate an access key)
  * Direct-attach the policy AdministratorAccess
  * Note the access key and secret key ID that are generated.
3. Using the aws command line tool, store the access key and secret key in a profile with a special name:
  `aws configure --profile inspec-aws-test-default`

#### Test Fixtures for the Default Account


### Creating the Minimal Account

## Running the integration tests

To run all AWS integration tests, run:

 ```
 bundle exec rake test:aws
 ```

To run the tests against one account only:

 ```
 bundle exec rake test:aws:defualt
 ```

 or

 ```
 bundle exec rake test:aws:minimal
 ```
 
Each account has separate tasks for setup, running the tests, and cleanup.  You may run them separately:

```
bundle exec rake test:aws:setup:defualt
bundle exec rake test:aws:run:defualt
bundle exec rake test:aws:cleanup:defualt
```


