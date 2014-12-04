require 'mongo'

include Mongo

client = MongoClient.new("integration-silkroad-app.dev.aws.bqreaders.local")

db = client['iam']
coll = db['user']

entry = coll.find

entry.each do |e|
    puts e['email'] unless e['email'].match(/test|fake/)
end

