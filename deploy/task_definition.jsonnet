// IF YOU EDIT ENVITORONMENT VARIABLES OR SECRETS, YOU SHOULD ALSO EDIT kaigionrails/terraform/aws/cfp-app/*.tf FILES.
{
  parameterStoreArn(name):: std.format('arn:aws:ssm:us-west-2:861452569180:parameter/cfp-app/%s', name),

  family: 'cfp-app-worker',
  runtimePlatform: { operatingSystemFamily: 'LINUX' },
  taskRoleArn: 'arn:aws:iam::861452569180:role/CfpApp',
  executionRoleArn: 'arn:aws:iam::861452569180:role/EcsExecCfpApp',
  networkMode: 'awsvpc',
  containerDefinitions: [
    {
      name: 'app',
      image: '861452569180.dkr.ecr.us-west-2.amazonaws.com/cfp-app:' + std.extVar('IMAGE_SHA'),
      cpu: 0,
      essential: true,
      command: ['bundle', 'exec', 'sidekiq', '--queue', 'default', '--timeout', '25'],
      environment: [
        {
          name: 'AWS_ACCESS_KEY_ID',
          value: 'sample',
        },
        {
          name: 'AWS_S3_BUCKET',
          value: 'sample',
        },
        {
          name: 'AWS_SECRET_ACCESS_KEY',
          value: 'sample',
        },
        {
          name: 'LANG',
          value: 'en_US.UTF-8',
        },
        {
          name: 'MAIL_FROM',
          value: 'noreply@kaigionrails.org',
        },
        {
          name: 'MAIL_HOST',
          value: 'cfp.kaigionrails.org',
        },
        {
          name: 'RACK_ENV',
          value: 'production',
        },
        {
          name: 'RAILS_ENV',
          value: 'production',
        },
        {
          name: 'RAILS_LOG_TO_STDOUT',
          value: 'enabled',
        },
        {
          name: 'SENTRY_ENV',
          value: 'production',
        }
        {
          name: 'TIMEZONE',
          value: 'Asia/Tokyo',
        },
      ],
      secrets: [
        {
          name: 'DATABASE_URL',
          valueFrom: $.parameterStoreArn('DATABASE_URL'),
        },
        {
          name: 'GITHUB_KEY',
          valueFrom: $.parameterStoreArn('GITHUB_KEY'),
        },
        {
          name: 'GITHUB_SECRET',
          valueFrom: $.parameterStoreArn('GITHUB_SECRET'),
        },
        {
          name: 'REDIS_TLS_URL',
          valueFrom: $.parameterStoreArn('REDIS_TLS_URL'),
        },
        {
          name: 'REDIS_URL',
          valueFrom: $.parameterStoreArn('REDIS_URL'),
        },
        {
          name: 'SECRET_KEY_BASE',
          valueFrom: $.parameterStoreArn('SECRET_KEY_BASE'),
        },
        {
          name: 'SENTRY_DSN',
          valueFrom: $.parameterStoreArn('SENTRY_DSN'),
        },
        {
          name: 'SLACK_WEBHOOK_URL',
          valueFrom: $.parameterStoreArn('SLACK_WEBHOOK_URL'),
        },
        {
          name: 'SMTP_ADDRESS',
          valueFrom: $.parameterStoreArn('SMTP_ADDRESS'),
        },
        {
          name: 'SMTP_DOMAIN',
          valueFrom: $.parameterStoreArn('SMTP_DOMAIN'),
        },
        {
          name: 'SMTP_PASSWORD',
          valueFrom: $.parameterStoreArn('SMTP_PASSWORD'),
        },
        {
          name: 'SMTP_USERNAME',
          valueFrom: $.parameterStoreArn('SMTP_USERNAME'),
        },
        {
          name: 'TWITTER_KEY',
          valueFrom: $.parameterStoreArn('TWITTER_KEY'),
        },
        {
          name: 'TWITTER_SECRET',
          valueFrom: $.parameterStoreArn('TWITTER_SECRET'),
        },
      ],
      logConfiguration: {
        logDriver: 'awslogs',
        options: {
          'awslogs-group': '/ecs/cfp-app-worker',
          'awslogs-region': 'us-west-2',
          'awslogs-stream-prefix': 'ecs',
        },
      },
    },
  ],
  cpu: '256',
  memory: '512',
  tags: [
    {
      key: 'Project',
      value: 'kaigionrails',
    },
  ],
}
