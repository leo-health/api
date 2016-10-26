SURVEYS = [{
   survey:{
       name: 'MCHAT',
       description: 'This is description',
       prompt:'This is prompt',
       instruction: 'This is instruction',
       reason: 'This is reason',
       survey_type: 'clinical'
   },
   questions: [
     { body: (<<-EOT),
If you point at something across the room, does your child look at it?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, if you point at a toy or an animal, does your child look at the toy or animal?
       EOT
       question_type: 'single select',
       order: 1
     },
     { body: (<<-EOT),
Have you ever wondered if your child might be deaf?
       EOT
       question_type: 'single select',
       order: 2
     },
     { body: (<<-EOT),
Does your child play pretend or make-believe?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, pretend to drink from an empty cup, pretend to talk on a phone, or pretend to feed a doll or stuffed animal?
       EOT
       question_type: 'single select',
       order: 3
     },
     { body: (<<-EOT),
Does your child like climbing on things?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, furniture, playground equipment, or stairs
       EOT
       question_type: 'single select',
       order: 4
     },
     { body: (<<-EOT),
Does your child make unusual finger movements near his or her eyes?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, does your child wiggle his or her fingers close to his or her eyes?
       EOT
       question_type: 'single select',
       order: 5
     },
     { body: (<<-EOT),
Does your child point with one finger to ask for something or to get help?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, pointing to a snack or toy that is out of reach
       EOT
       question_type: 'single select',
       order: 6
     },
     { body: (<<-EOT),
Does your child point with one finger to show you something interesting?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, pointing to an airplane in the sky or a big truck in the road
       EOT
       question_type: 'single select',
       order: 7
     },
     { body: (<<-EOT),
Is your child interested in other children?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, does your child watch other children, smile at them, or go to them?
       EOT
       question_type: 'single select',
       order: 8
     },
     { body: (<<-EOT),
Does your child show you things by bringing them to you or holding them up for you to see – not to get help, but just
to share?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, showing you a flower, a stuffed animal, or a toy truck
       EOT
       question_type: 'single select',
       order: 9
     },
     { body: (<<-EOT),
Does your child respond when you call his or her name?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, does he or she look up, talk or babble, or stop what he or she is doing when you call his or her name?
       EOT
       question_type: 'single select',
       order: 10
     },
     { body: (<<-EOT),
When you smile at your child, does he or she smile back at you?
       EOT
       question_type: 'single select',
       order: 11
     },
     { body: (<<-EOT),
Does your child get upset by everyday noises?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, does your child scream or cry to noise such as a vacuum cleaner or loud music?
       EOT
       question_type: 'single select',
       order: 12
     },
     { body: (<<-EOT),
Does your child walk?
       EOT
       question_type: 'single select',
       order: 13
     },
     { body: (<<-EOT),
Does your child look you in the eye when you are talking to him or her, playing with him Yes No or her, or dressing
him or her?
       EOT
       question_type: 'single select',
       order: 14
     },
     { body: (<<-EOT),
Does your child try to copy what you do?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, wave bye-bye, clap, or make a funny noise when you do
       EOT
       question_type: 'single select',
       order: 15
     },
     { body: (<<-EOT),
If you turn your head to look at something, does your child look around to see what you are looking at?
       EOT
       question_type: 'single select',
       order: 16
     },
     { body: (<<-EOT),
Does your child try to get you to watch him or her?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, does your child look at you for praise, or say “look” or “watch me”?
       EOT
       question_type: 'single select',
       order: 17
     },
     { body: (<<-EOT),
Does your child understand when you tell him or her to do something?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, if you don’t point, can your child understand “put the bookon the chair” or “bring me the blanket”?
       EOT
       question_type: 'single select',
       order: 18
     },
     { body: (<<-EOT),
If something new happens, does your child look at your face to see how you feel about it?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, if he or she hears a strange or funny noise, or sees a new toy, willhe or she look at your face?
       EOT
       question_type: 'single select',
       order: 19
     },
     { body: (<<-EOT),
Does your child like movement activities?
       EOT
       secondary: (<<-EOT),
FOR EXAMPLE, being swung or bounced on your knee
       EOT
       question_type: 'single select',
       order: 20
     }
   ]
}]
