;; Jacob comments:
;; Comments about the conceptualization of the model are either in my email to you or in comments on your document.
;; Comments below are specifically about NetLogo coding and are surrounded in triple curly braces: {{{ comment }}}

;Agents start with a random amount of economic capital, aka money.
;If they have more than zero money, they will randomly be exploring
;the world. If actors have no money, they will stop and work, until
;they have enough money. Alternatively, they could borrow some money
;from their link neighbors. What neighbors? If actor encounter another
;actor and if money more than some value, than they create-link-with
;them, a.k.a. meet friends.
undirected-link-breed [ friendships friendship ]

breed [actors actor]

globals [avg-economic-capital]

turtles-own [
  economic-capital
  social-capital  ; {{{ Since this is just equal to count link neighbors, I would make it a reporter instead of a turtle-owns variable }}}
]

to setup
  clear-all
  reset-ticks
  set-default-shape turtles "person"
  create-actors population-size [
    setxy random-xcor random-ycor
    set economic-capital random-normal 50 20
  ]
  set avg-economic-capital mean [economic-capital] of turtles
end

to go
  ask turtles [
    if economic-capital > 0 [
      move
      explore
    ]
    if economic-capital <= 0 [
      work-or-borrow
    ]
  ]
  set avg-economic-capital mean [economic-capital] of turtles
  tick
  if ticks > 1000 [stop]
end

to move
  set economic-capital economic-capital - 5
  rt random-float 360
  fd 1
end

to explore  ; {{{ I don't like this being called "explore." Name it something that has to do with making social connections }}}
  if economic-capital > 0 [
    let posstible-neighbors other turtles-here with [economic-capital > 0 and not link-neighbor? myself]
    if any? posstible-neighbors [
      let friend one-of posstible-neighbors 
      if friend != nobody [
        create-link-with friend
        set economic-capital economic-capital - 10
        
        ask friend [
          set economic-capital economic-capital - 5
        ]
      ]
    ]
  ]

 set social-capital count link-neighbors
end

to work-or-borrow
  ifelse any? link-neighbors with [economic-capital > 0] [
    let lender one-of link-neighbors with [economic-capital > 0]
    let amount random 15
    ;; {{{ You are calling this lending, but it never gets paid back ... }}}
    ask lender [
      if economic-capital >= amount [
        set economic-capital economic-capital - amount
        ask myself [
          set economic-capital economic-capital + amount
        ]
        
      ]
    ]
  ]  [
    set economic-capital economic-capital + 10
  ]
end





