Dir.glob('./{helpers,controllers,forms,services}/*.rb').each { |file| require file }
run AppController
