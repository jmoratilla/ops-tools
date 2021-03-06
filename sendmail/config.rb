HOST = [
        'mi-casa',
        'qa-silkroad-app.dev',
        'integration-silkroad-app.dev',
        'staging-silkroad-app-1.staging-silkroad',
        'staging-silkroad-app-2.staging-silkroad',
        'production-silkroad-app-1.production-silkroad',
        'production-silkroad-app-2.production-silkroad',
        'dev-books-app.dev',
        'dev-books-front.dev',
        'dev-books-front-sf.dev',
        'integration-books-app.dev',
        'qa-books-app.dev',
        'qa-books-front.dev',
        'qa-books-front-sf.dev',
        'qa2-books-app.dev',
        'qa2-books-front.dev',
        'qa-silkroad-app.dev',
        'current-silkroad-app.dev',
        'next-silkroad-app.dev',
        'current-silkroad-app.dev',
        'integration-orpheus-app.dev',
        'integration-orpheus-app2.dev',
        'integration-magsap-silkroad-app.dev',
        'staging-ws-1.staging-statics',
        'staging-ws-2.staging-statics',
        'production-ws-1.production-statics',
        'production-ws-2.production-statics',
        'staging-books-admin-1.staging-books',
        'staging-books-api-1.staging-books',
        'staging-books-api-2.staging-books',
        'staging-books-backstage.staging-books',
        'staging-books-front-1.staging-books',
        'staging-books-front-2.staging-books',
        'staging-books-front-sf-1.staging-books',
        'staging-books-front-sf-2.staging-books',
        'prod-books-api-1.prod-books',
        'prod-books-api-2.prod-books',
        'prod-books-front-1.prod-books',
        'prod-books-front-2.prod-books',
        'staging-mongodb-shard0-a.staging-silkroad',
        'staging-mongodb-shard0-b.staging-silkroad',
        'staging-mongodb-shard0-c.staging-silkroad',
        'production-mongodb-shard0-a.production-silkroad',
        'production-mongodb-shard0-b.production-silkroad',
        'production-mongodb-shard0-c.production-silkroad',
        'staging-silkroad-mq-1.staging-silkroad',
        'staging-silkroad-mq-2.staging-silkroad',
        'production-silkroad-mq-1.production-silkroad',
        'production-silkroad-mq-2.production-silkroad',
        'staging-silkroad-beanstalkd-master.staging-silkroad',
        'staging-silkroad-redis-master.staging-silkroad',
        'production-silkroad-beanstalkd-master.production-silkroad',
        'production-silkroad-redis-master.production-silkroad',
]

DOMAIN = '.aws.bqreaders.local'
USER = 'ec2-user'
KEYS = [
        "#{ENV['HOME']}/.chef/silkroad-dev.pem",
        "#{ENV['HOME']}/.chef/books-dev.pem",
        "#{ENV['HOME']}/.chef/books-prod.pem",
        "#{ENV['HOME']}/.chef/silkroad-prod.pem",
        "#{ENV['HOME']}/.chef/orpheus-dev.pem",
        "#{ENV['HOME']}/.chef/orpheus-prod.pem",
]

