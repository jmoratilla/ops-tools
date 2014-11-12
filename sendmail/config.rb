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
        'integration-books-app.dev',
        'qa-books-app.dev',
        'qa-books-front.dev',
        'qa2-books-app.dev',
        'qa2-books-front.dev',
        'staging-books-admin-1.staging-books',
        'staging-books-api-1.staging-books',
        'staging-books-api-2.staging-books',
        'staging-books-backstage.staging-books',
        'staging-books-front-1.staging-books',
        'staging-books-front-2.staging-books',
        'prod-books-api-1.prod-books',
        'prod-books-api-2.prod-books',
        'prod-books-front-1.prod-books',
        'prod-books-front-2.prod-books'
]

DOMAIN = '.aws.bqreaders.local'
USER = 'ec2-user'
KEYS = [
        "#{ENV['HOME']}/.chef/silkroad-dev.pem",
        "#{ENV['HOME']}/.chef/books-dev.pem",
        "#{ENV['HOME']}/.chef/books-prod.pem",
]

