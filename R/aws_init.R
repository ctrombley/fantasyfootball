library(aws.signature)
library(configr)

config = read.config(file = 'config.yaml')
Sys.setenv( "AWS_ACCESS_KEY_ID" = config$aws_access_key_id,
            "AWS_SECRET_ACCESS_KEY" = config$aws_secret_access_key)