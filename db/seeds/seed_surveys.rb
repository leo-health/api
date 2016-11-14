class SeedSurveys
  def self.seed
    surveys.each do |survey_json|
      survey_id = Survey.update_or_create!(:name, survey_json).id
      mchat_questions.each_with_index do |question_json, index|
        Question.update_or_create!([:survey_id, :order], question_json.merge(survey_id: survey_id, order: index, question_type: "single select"))
      end
    end

    count = {survey: Survey.count, question: Question.count}
    puts "Finished seeding #{count[:survey]} surveys and #{count[:question]} questions"
  end

  def self.surveys
    [
        {
            name: 'MCHAT18',
            description: 'This is description',
            prompt:'This is prompt',
            instructions: 'This is instruction',
            reason: 'This is reason',
            survey_type: 'clinical'
        },
        {
            name: 'MCHAT24',
            description: 'This is description',
            prompt:'This is prompt',
            instructions: 'This is instruction',
            reason: 'This is reason',
            survey_type: 'clinical'
        }
    ]
  end

  def self.mchat_questions
    [
        {
            body: "If you point at something across the room, does your child look at it?",
            secondary: "FOR EXAMPLE, if you point at a toy or an animal, does your child look at the toy or animal?"
        },
        {
            body: "Have you ever wondered if your child might be deaf?"
        },
        {
            body: "Does your child play pretend or make-believe?",
            secondary: "FOR EXAMPLE, pretend to drink from an empty cup, pretend to talk on a phone, or pretend to feed a doll or stuffed animal?"
        },
        {
            body: "Does your child like climbing on things?",
            secondary: "FOR EXAMPLE, furniture, playground equipment, or stairs"
        },
        {
            body: "Does your child make unusual finger movements near his or her eyes?",
            secondary: "FOR EXAMPLE, does your child wiggle his or her fingers close to his or her eyes?"
        },
        {
            body: "Does your child point with one finger to ask for something or to get help?",
            secondary: "FOR EXAMPLE, pointing to a snack or toy that is out of reach"
        },
        {
            body: "Does your child point with one finger to show you something interesting?",
            secondary: "FOR EXAMPLE, pointing to an airplane in the sky or a big truck in the road"
        },
        {
            body: "Is your child interested in other children?",
            secondary: "FOR EXAMPLE, does your child watch other children, smile at them, or go to them?"
        },
        {
            body: "Does your child show you things by bringing them to you or holding them up for you to see – not to get help, but just to share?",
            secondary: "FOR EXAMPLE, showing you a flower, a stuffed animal, or a toy truck"
        },
        {
            body: "Does your child respond when you call his or her name?",
            secondary: "FOR EXAMPLE, does he or she look up, talk or babble, or stop what he or she is doing when you call his or her name?"
        },
        {
            body: "When you smile at your child, does he or she smile back at you?"
        },
        {
            body: "Does your child get upset by everyday noises?",
            secondary: "FOR EXAMPLE, does your child scream or cry to noise such as a vacuum cleaner or loud music?"
        },
        {
            body: "Does your child walk?"
        },
        {
            body: "Does your child look you in the eye when you are talking to him or her, playing with him Yes No or her, or dressing"
        },
        {
            body: "Does your child try to copy what you do?",
            secondary: "FOR EXAMPLE, wave bye-bye, clap, or make a funny noise when you do"
        },
        {
            body: "If you turn your head to look at something, does your child look around to see what you are looking at?"
        },
        {
            body: "Does your child try to get you to watch him or her?",
            secondary: "FOR EXAMPLE, does your child look at you for praise, or say “look” or “watch me”?"
        },
        {
            body: "Does your child understand when you tell him or her to do something?",
            secondary: "FOR EXAMPLE, if you don’t point, can your child understand “put the bookon the chair” or “bring me the blanket”?"
        },
        {
            body: "If something new happens, does your child look at your face to see how you feel about it?",
            secondary: "FOR EXAMPLE, if he or she hears a strange or funny noise, or sees a new toy, willhe or she look at your face?"
        },
        {
            body: "Does your child like movement activities?",
            secondary: "FOR EXAMPLE, being swung or bounced on your knee"
        }
    ]
  end
end
