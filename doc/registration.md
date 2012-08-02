# registration for organizer

Registration
  has_one :organizer
  has_one :person # may be derived

Registration process
0. register yourself (creates a registration, organizer, and person )
0. add profile fields (to person)
0. create account and notify
0. login to create a location (optional)

# registration for conversation leader 

0. register yourself (creates a registration, cl, and person )
0. add profile fields ( to person )
0. choose trainings
0. create account and notify

# registration for participant 
0. register yourself (creates a registration, particiapnt, and person )
0. add profile fields ( to person )
0. create account and notify

# consequences
* account should not just send a confirmation mail on creation
* after completing the registration an account confirmation mail needs
  to be sent
** something like person.notify_account and/or account.notify
** or add an email field in person to prevent the account to be created automatically and update email in account as well as in person when changed and account exists 
* a registration may be abandoned. when that happens
** account is created without confirmation (don't want that as one can then login by resetting the account)
* need to be clear about registration not complete untill all steps done
* person should have a conceptual stage - when person is not really
  registered yet
* when persons are collected (listed) only the alive people should be
  listed
* person becomes alive (from conception) at end of the registration

# Todo 
* add registration
** contributor
** person
** conversation
** ip (from request)
** hash_code

* add status field to person
** default is conceptual
** migrate all to alive

* participant registration
** create creates registration (with conceptual person name, email,
telephone)
** create redirects to profile
** update profile updates profile 
** update profile completes the registration ( makes the person alive, creates the accoount, creates the participant )

* conversation leader registration
** create creates registration (with conceptual person name, email,
telephone)
** create redirects to profil
** update profile updates profile
** update profile redirects to choose trainings
** update update trainings completes the registrations { mkaes the
person alive, creates the account, creates the coversation_leader )

* organizer registration
** similar to participant

