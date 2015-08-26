namespace :session do
	desc "Create a session for a guardian user based on the number of children in a family."
	task login: :environment do
		puts "How many children would you like this family to have (0-4)?"
		answer = STDIN.gets.chomp.to_i
		if (family = Family.find_by_id(answer+1)) ? true:false
			if (patients = family.patients) ? true:false
				ap patients
			else
				print "Error - #{patients.errors.full_messages}"
			end
			if(guardian = family.guardians.first) ? true:false
				guardian.sessions.create
				ap guardian
				ap guardian.sessions.first
			else
				print "Error - #{guardian.errors.full_messages}".red
			end
		else
			print "Error - #{family.errors.full_messages}".red
		end
	end
end
