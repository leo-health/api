module HealthRecordHelper
  ATHENA_VACCINE_NAMES = [
    "ActHIB (PF) 10 mcg/0.5 mL intramuscular solution", "Adacel (Tdap Adolesn/Adult)(PF)2 Lf-(2.5-5-3-5)-5 Lf/0.5 mL IM syringe",
    "Daptacel (DTaP Pediatric) (PF) 15 Lf unit-10 mcg-5 Lf/0.5 mL IM susp", "Gardasil 9 (PF) 0.5 mL intramuscular suspension",
    "IPOL 40 unit-8 unit-32 unit/0.5 mL suspension for injection", "M-M-R II (PF) 1,000-12,500 TCID50/0.5 mL subcutaneous solution",
    "Menactra (PF) 4 mcg/0.5 mL intramuscular solution", "Prevnar 13 (PF) 0.5 mL intramuscular syringe",
    "Recombivax HB (PF) 5 mcg/0.5 mL intramuscular suspension", "RotaTeq Vaccine 2 mL oral suspension",
    "Vaqta (PF) 25 unit/0.5 mL intramuscular suspension", "Varivax (PF) 1,350 unit/0.5 mL subcutaneous suspension",
    "Trumenba 120 mcg/0.5 mL intramuscular syringe", "diphtheria, tetanus toxoids and acellular pertussis vaccine",
    "diphtheria, tetanus toxoids and acellular pertussis vaccine, 5 pertussis antigens",
    "diphtheria, tetanus toxoids and acellular pertussis vaccine, and poliovirus vaccine, inactivated",
    "diphtheria, tetanus toxoids and acellular pertussis vaccine, haemophilus influenzae type b conjugate, and poliovirus vaccine, inactivated (DTaP-Hib-IPV)",
    "diphtheria, tetanus toxoids and acellular pertussis vaccine, unspecified formulation", "diphtheria, tetanus toxoids and pertussis vaccine",
    "DTaP-hepatitis B and poliovirus vaccine", "Fluzone Quad Pedi 2015-16 (PF) 30 mcg (7.5 mcg x 4)/0.25 mL IM syringe",
    "haemophilus influenzae type b conjugate and hepatitis B vaccine", "haemophilus influenzae type b vaccine, conjugate unspecified formulation",
    "haemophilus influenzae type b vaccine, HbOC conjugate", "haemophilus influenzae type b vaccine, PRP-OMP conjugate",
    "haemophilus influenzae type b vaccine, PRP-T conjugate", "Hep A, live attenuated-IM",
    "hepatitis A vaccine, pediatric dosage, unspecified formulation", "hepatitis A vaccine, pediatric/adolescent dosage, 2 dose schedule",
    "hepatitis A vaccine, unspecified formulation", "hepatitis B vaccine, adolescent/high risk infant dosage",
    "hepatitis B vaccine, dialysis patient dosage", "hepatitis B vaccine, pediatric or pediatric/adolescent dosage",
    "hepatitis B vaccine, unspecified formulation", "Infanrix (DTaP)(PF) 25 Lf unit-58mcg-10 Lf/0.5mL intramuscular syringe",
    "influenza virus vaccine, live, attenuated, for intranasal use", "influenza virus vaccine, split virus (incl. purified surface antigen)-retired code",
    "influenza virus vaccine, unspecified formulation", "influenza, injectable, quadrivalent, contains preservative",
    "Influenza, injectable, quadrivalent, preservative free", "Influenza, injectable,quadrivalent, preservative free, pediatric",
    "influenza, live, intranasal, quadrivalent", "influenza, seasonal, injectable",
    "influenza, seasonal, injectable, preservative free", "measles virus vaccine",
    "measles, mumps and rubella virus vaccine", "measles, mumps, rubella, and varicella virus vaccine",
    "meningococcal B, recombinant", "meningococcal C conjugate vaccine", "meningococcal polysaccharide vaccine (MPSV4)",
    "meningococcal vaccine, unspecified formulation", "novel influenza-H1N1-09, all formulations",
    "novel influenza-H1N1-09, injectable", "pneumococcal conjugate vaccine, 13 valent", "pneumococcal conjugate vaccine, 7 valent",
    "pneumococcal vaccine, unspecified formulation", "poliovirus vaccine, inactivated", "poliovirus vaccine, unspecified formulation",
    "Recombivax HB (PF) 10 mcg/mL intramuscular suspension", "rotavirus vaccine, unspecified formulation", "rotavirus, live, monovalent vaccine",
    "rotavirus, live, pentavalent vaccine", "rotavirus, live, tetravalent vaccine", "Seasonal trivalent influenza vaccine, adjuvanted, preservative free",
    "tetanus toxoid, reduced diphtheria toxoid, and acellular pertussis vaccine, adsorbed", "typhoid Vi capsular polysaccharide vaccine",
    "varicella virus vaccine"
  ]
  VACCINE_DISPLAY_NAMES = [
    "HiB", "TdaP", "DTaP", "HPV", "Polio", "MMR", "Menactra (Meningococcal)", "Pneumococcal", "Hepatitis B", "Rota", "Hepatitis A",
    "Chicken Pox", "Meningococcal B", "DTaP", "DTaP", "DTaP", "DTaP", "DTaP", "DTaP", "DTaP", "Flu", "HiB", "HiB", "HiB", "HiB",
    "HiB", "Hepatitis A", "Hepatitis A", "Hepatitis A", "Hepatitis A", "Hepatitis B", "Hepatitis B", "Hepatitis B", "Hepatitis B",
    "DTaP", "Flu", "Flu", "Flu", "Flu", "Flu", "Flu", "Flu", "Flu", "Flu", "Measles", "MMR", "MMR-Chicken Pox", "Meningococcal B",
    "Menactra (Meningococcal)", "Menactra (Meningococcal)", "Menactra (Meningococcal)", "Flu", "Flu", "Pneumococcal", "Pneumococcal",
    "Pneumococcal", "Polio", "Polio", "Hepatitis B", "Rota", "Rota", "Rota", "Rota", "Flu", "TdaP", "Typhoid", "Chicken Pox"
  ]
  VACCINE_NAME_MAP = ATHENA_VACCINE_NAMES.each_with_index.inject({}) do |map, (vaccine, idx)|
    map[vaccine] = VACCINE_DISPLAY_NAMES[idx]
    map
  end
end
