desc "updates training participant_caches"
task :update_training_caches => :environment do
   Training.unscoped do
     TrainingRegistration.unscoped do 
       Training.all.each {|t| Training.update_counters(t.id, :participant_count => t.training_registrations.count)} 
     end
   end
end
