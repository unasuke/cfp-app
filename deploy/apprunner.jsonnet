{
  ServiceArn: 'arn:aws:apprunner:us-west-2:861452569180:service/cfp-app/5171a8a89c8f40a9a232a0236c0d1008',
  SourceConfiguration: {
    ImageRepository: {
      ImageIdentifier: '861452569180.dkr.ecr.us-west-2.amazonaws.com/cfp-app:' + std.extVar('IMAGE_SHA'),
      ImageRepositoryType: 'ECR',
    },
  },
}
