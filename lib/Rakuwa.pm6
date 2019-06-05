module Rakuwa {
  sub greeting ($name = 'Camelia') { "Greetings, $name!" }
  our sub loud-greeting (--> Str)  { greeting().uc       }
  sub friendly-greeting is export  { greeting('friend')  }
}
