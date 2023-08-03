# Notes

## API Gateway

In AWS API Gateway, the base URL for REST APIs is
in the following format:

  https://{restapi_id}.execute-api.{region}.amazonaws.com/{stage_name}/

where:

+ {restapi_id} is the API identifier
+ {region} is the Region
+ {stage_name} is the stage name of the API deployment

Localstack uses a special URL path to indicate the
execution of a REST API method:

  /_user_request_/

So, the base URL pattern for API Gateway
in localstack is:

  http://localstack:4566/restapis/{restapi_id}/{stage_name}/_user_request_/

## Running aws cli against running localstack

You can either use the `awscli-local` tool from localstack or you can use the
`laws` that I've made which will use the aws cli 2 docker image from Amazon and
a customized environment to isolate use of the aws cli from our real AWS cloud
use.

The `laws` script will also mount this project dir into the aws-cli container.

## Terraform on localstack

You can use the `terraform/main.tf` as a template for deploying services to the
localstack instance from terraform. You can set the vars in a tfvars file, use
the `-var` param to terraform or set them as environment variables by prefixing
any var with `TF_VAR_` in the env.

TODO(jjwatt): Still working on modularizing the terraform here. Right now, the
state this is in is getting things working ASAP (did all this in about a day).
In the end, I will be using terraform modules and providing ways for plugging
in other lambda functions, including non-Golang ones and "real" ones from GR.

## Lambdas

Using Go for now to get the hang of lambdas + terraform + localstack, and
because I'd like to try out Terratest.

### Valid lambda function handler signatures in Go

+ the handler must be a function
+ the handler amy take 0-2 arguments
  - if 2 arguments, the first arg must implement `context.Context`
+ the handler may return 0-2 arguments
  - if 1 return value, it *must* be an error
  - if 2 return values, the second value *must* be an error

```go
func ()
func () error
func (tIn) error
func () (tOut, error)
func (context.Context) error
func (context.Context, tIn) error
func (context.Context) (tOut, error)
func (context.Context, tIn) (tOut, error)
```

### AWS Lambda Context (in Go)

AWS Lambda passes a context object to the handler.

> The object provides methods and properties with information about the
> invocation, function, and execution environment.

|      Property      |                       Description                      |
|:------------------:|:------------------------------------------------------:|
|    FunctionName    |             The name of the Lambda function            |
|  FunctionVersion   |               The version of the function              |
|  MemoryLimitInMB   |  The amount of memory thats allocated for the function |
|    LogGroupName    |             The log group for the function             |
|   LogStreamName    |        The log stream for the function instance        |
| InvokedFunctionArn |        The ARN thats used to invoke the function       |
|    AwsRequestID    |        The identifier of the invocation request        |

```go
package main

import (
	"context"
	"log"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/lambdacontext"
)

func handler(ctx context.Context) {
	lc, - := lambdacontext.FromContext(ctx)
	log.Printf("Req ID: %s\n", lc.AwsRequestID)
}
func main() {
	lambda.Start(handler)
}
```

### Invoking Lambda functions

Lambdas can be invoked:

* using the AWS Console, SDK or AWS CLI
* by other AWS services
* synchronously or asynchronously
	* RequestResponse - synchronously
	* Event - asynchronously
 
#### Synchronous Invocation

```shell
$ ▶ aws lambda invoke --function-name $(FUNCTION) \
--cli-binary-format raw-in-base64-out --payload '$(JSON_PAYLOAD)' $(OUTPUT_FILE)
{
"StatusCode": 200,
https://github.com/jjwatt/
}
"ExecutedVersion": "$LATEST" 
```

#### Asynchronous Invocation

Many AWS services like s3 and sns invoke functions asynchronously to process events.

To invoke a function async, set the `--invocation-type` to `Event`

```shell
$ ▶ aws lambda invoke --function-name $(FUNCTION) --invocation-type Event \ https://twitter.com/lucasepe/
--cli-binary-format raw-in-base64-out --payload '$(JSON_PAYLOAD)' $(OUTPUT_FILE)
{
"StatusCode": 202,
https://github.com/jjwatt/
"ExecutedVersion": "$LATEST" }
```

### AWS Lambda Security

A Lambda's execution role is an AWS Identity and Access Management (IAM) role
that grants the function permission to access AWS services and resources.

* Lambda assumes this role when the function is invoked
* A lambda at least needs permission to upload logs to CloudWatch (`AWSLambdaBasicExecutionRole`)
* You can add more policies for other access (s3, sns, sqs, etc)

#### Execution Policies

A policy specifies:

* Actions - which service actions to allow
* Resources - which resources to allow actions on
* Effect - allow or deny
* Conditions - optional conditions for the policy to take effect

Create basic execution role:

	```terraform        
	resource "aws_iam_role" "lambda" {
	  name               = "${var.function_name}-${data.aws_region.current.name}"
	  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
	}

	data "aws_iam_policy_document" "assume_role_policy" {
	  statement {
	    actions = ["sts:AssumeRole"]

	    principals {
	      type        = "Service"
	      identifiers = ["lambda.amazonaws.com"]
	    }
	  }
	}
	```

Create basic execution role and add policy attachment:

	```terraform        
	resource "aws_iam_role" "lambda" {
	  name               = "${var.function_name}-${data.aws_region.current.name}"
	  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
	}

	resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
	  role       = aws_iam_role.lambda.name
	  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
	}

	data "aws_iam_policy_document" "assume_role_policy" {
	  statement {
	    actions = ["sts:AssumeRole"]

	    principals {
	      type        = "Service"
	      identifiers = ["lambda.amazonaws.com"]
	    }
	  }
	}
        ```

The resource is called `cloudwatch_logs` here because it uses a service role
"Amazon Managed Policy" called `AWSLambdaBasicExecutionRole` which should setup
all the actions and resource permissions to allow our lambda arn to create and
write to log streams.

NOTE: This works in localstack, too, because Localstack has mocks for many AWS
managed policies.

IDEA: Besides getting "real" lambdas to work, a fun side project could be to
write a set of lambdas for RFC6902 (JSON Patch) and RFC7396 (JSON Merge Patch).
I wonder how much of what GR's dedicated lambdas could be covered by general
lambdas like that. Similar idea for stuff like JSON Schema checks and
generation, maybe even go as far as JSON-RPC or OpenRPC. Though, note that JSON
Schema isn't used universily or even that much at GR (yet?). I've noticed that
GR's lambda services always seem to convert incoming JSON documents to clj or
edn, and they usually convert from edn or clj to JSON before returning values.
What if they worked on the "native" documents and objects?

## Rework

I'm reworking this example/poc. Firstly, I want it to run with javascript, and as I see all the changes that need to be made for that, it's making me want to rework it to be more modular.

1.  The localstack runner should be separated and "optional"
	- Someone might want to run lambda(s) on their own running localstack
	- Since it's an example, the idea is that multiple projects might be setup similarly, but all deploying to a shared localstack instance locally or in CI
2.  The terraform should be modular and should be able to deploy the lambdas to a running localstack or even to a real temporary AWS instance


