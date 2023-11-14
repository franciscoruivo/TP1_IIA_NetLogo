breed [ lions lion ]
breed [ hyenas hyena ]
breed[cacadores cacador]

turtles-own [ energy ]

hyenas-own [ groupingLevel ]
lions-own [ restTime onRest ]

;balas var que possibilita os cacadores de matar
;recarga quando de balas quando o cacador entra no seu abrigo
cacadores-own[balas recarga nalimentobrown nalimentored]

to setup
  setup-patches
  setup-turtles
  reset-ticks
  display-labels
end

to go
  move-lions
  move-hyenas
  hyenas-perceciona-drops
  lions-perceciona-drops
  cacador-acao
  check-death
  respawn-food
  display-labels
  if count lions = 0 or count hyenas = 0 or ticks = 500 [ stop ]
  tick
end

to setup-patches
  clear-all
  set-patch-size 15
  reset-ticks
  ask patches [
    if random 101 <= littleFood [ set pcolor brown ]
    if random 101 <= bigFood [ set pcolor red ]
  ]
  ask n-of blueCells patches with [ pcolor = black ] [ set pcolor blue ]
  ask n-of ntraps patches with [ pcolor = black ] [ set pcolor orange ]
   ask n-of dropbonus patches[
      if pcolor != brown and pcolor != red and pcolor != red and pcolor != blue and pcolor != orange [
        set pcolor magenta
      ]
  ]
end

to setup-turtles
  clear-turtles
  create-lions lionsQty [
    set shape "arrow"
    set color yellow
    set restTime rest
    setxy random-xcor random-ycor
    while [ [ pcolor ] of patch-here != black ] [
      setxy random-xcor random-ycor
    ]
  ]
  create-hyenas hyenasQty [
    set shape "arrow"
    set color grey
    set groupingLevel 1
    setxy random-xcor random-ycor
    while [ [pcolor ] of patch-here != black ] [
      setxy random-xcor random-ycor
    ]
  ]
    create-cacadores ncacadores[
    set shape "person"
    set color  white
    setxy random-pxcor random-pycor
    set heading 0
    while [ [pcolor] of patch-here != black]
      [setxy random-pxcor random-pycor]
  ]

    ask cacadores
  [
    set recarga 0
    set balas 15
  ]
  ask turtles [
    set energy initialEnergy
    set heading 90
  ]
end

to move-lions
  ask lions
  [
    let left-color [ pcolor ] of patch-left-and-ahead 90 1
    let right-color [ pcolor ] of patch-right-and-ahead 90 1
    let front-color [ pcolor ] of patch-ahead 1
    ifelse left-color = blue or right-color = blue or front-color = blue
    [
      ifelse restTime = 0
      [
        set restTime rest
        set onRest 0
        move-forward
      ]
      [
        set onRest 1
        set restTime restTime - 1
      ]
    ]
    [
      ifelse energy < minEnergyLevel
      [
        ifelse [ pcolor ] of patch-here = brown
        [
          eat-little-food
        ]
        [
          ifelse [ pcolor ] of patch-here = red
          [
            eat-big-food
          ]
          [
            ifelse random 101 <= 80
            [
              move-forward
            ]
            [
              ifelse random 101 <= 50
              [
                rotate-left
              ]
              [
                rotate-right
              ]
            ]
          ]
        ]
      ]
      [
        ifelse special-moves
        [

        ]
        [
          ifelse [ pcolor ] of patch-here = brown
          [
            eat-little-food
          ]
          [
            ifelse [ pcolor ] of patch-here = red
            [
              eat-big-food
            ]
            [
              ifelse challenge-hyenas
              [

              ]
              [
                ifelse random 101 <= 80
                [
                  move-forward
                ]
                [
                  ifelse 101 <= 50
                  [
                    rotate-left
                  ]
                  [
                    rotate-right
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end

to move-hyenas
  ask hyenas
  [
    check-grouping-level
    ifelse groupingLevel > 1
    [
      ;set color green
    ]
    [
      set color grey
    ]
    ifelse [ pcolor ] of patch-here = brown
    [
      eat-little-food
    ]
    [
      ifelse [ pcolor ] of patch-here = red
      [
        eat-big-food
      ]
      [
        ifelse groupingLevel > 1
        [
          ifelse challenge-lions
          [

          ]
          [
            ifelse random 101 <= 80
            [
              move-forward
            ]
            [
              ifelse random 101 <= 50
              [
                rotate-left
              ]
              [
                rotate-right
              ]
            ]
          ]
        ]
        [
          ifelse random 101 <= 80
          [
            move-forward
          ]
          [
            ifelse random 101 <= 50
            [
              rotate-left
            ]
            [
              rotate-right
            ]
          ]
        ]
      ]
    ]
  ]
   reproduzir-hyenas ;cajo esteja no mm patch tem prob de reproduzir outro basic com ajuda do slider%
end

to check-grouping-level
  let leftPatch patch-at 90 1
  let leftHyenas count hyenas-on leftPatch
  let rightPatch patch-at -90 1
  let rightHyenas count hyenas-on rightPatch
  let frontPatch patch-ahead 1
  let frontHyenas count hyenas-on frontPatch
  set groupingLevel leftHyenas + rightHyenas + frontHyenas
end

to move-forward
  fd 1
  set energy energy - 1
end

to rotate-left
  lt 90
  set energy energy - 1
end

to rotate-right
  rt 90
  set energy energy - 1
end

to eat-little-food
  set energy energy + energyLittleFood
  set pcolor black
end

to eat-big-food
  set energy energy + energyBigFood
  set pcolor brown
end

to-report special-moves
  let leftPatch patch-at 90 1
  let leftHyenas count hyenas-on leftPatch
  let rightPatch patch-at -90 1
  let rightHyenas count hyenas-on rightPatch
  let frontPatch patch-ahead 1
  let frontHyenas count hyenas-on frontPatch
  ifelse leftHyenas >= 2 and rightHyenas = 0 and frontHyenas = 0
  [
    jump-right
    report true
  ]
  [
    ifelse rightHyenas >= 2 and leftHyenas = 0 and frontHyenas = 0
    [
      jump-left
      report true
    ]
    [
      ifelse (frontHyenas >= 2 and leftHyenas = 0 and rightHyenas = 0) or (leftHyenas >= 1 and rightHyenas >= 1 and frontHyenas = 0)
      [
        jump-back
        report true
      ]
      [
        ifelse leftHyenas >= 1 and frontHyenas >= 1 and rightHyenas = 0
        [
          jump-right-back
          report true
        ]
        [
          ifelse rightHyenas >= 1 and frontHyenas >= 1 and leftHyenas = 0
          [
            jump-left-back
            report true
          ]
          [
            ifelse leftHyenas >= 1 and rightHyenas >= 1 and frontHyenas >= 1
            [
             jump-2-back
             report true
            ]
            [
              report false
            ]
          ]
        ]
      ]
    ]
  ]
end

to jump-right
  rt 90
  fd 1
  set energy energy - 2
end

to jump-left
  lt 90
  fd 1
  set energy energy - 2
end

to jump-back
  bk 1
  rt 90
  set energy energy - 3
end

to jump-right-back
  bk 1
  rt 90
  fd 1
  set energy energy - 5
end

to jump-left-back
  bk 1
  lt 90
  fd 1
  set energy energy - 5
end

to jump-2-back
  bk 2
  rt 180
  set energy energy - 4
end

to-report challenge-hyenas
  let leftPatch patch-at 90 1
  let leftHyenas count hyenas-on leftPatch
  let rightPatch patch-at -90 1
  let rightHyenas count hyenas-on rightPatch
  let frontPatch patch-ahead 1
  let frontHyenas count hyenas-on frontPatch
  ifelse leftHyenas = 1 and rightHyenas = 0 and frontHyenas = 0
  [
    let hyenaToFight one-of hyenas-on leftPatch
    set energy energy - ( [ energy ] of hyenaToFight * loseEnergyOnFight )
    ask hyenaToFight [ die ]
    ask leftPatch
    [
      set pcolor brown
    ]
    report true
  ]
  [
    ifelse leftHyenas = 0 and rightHyenas = 1 and frontHyenas = 0
    [
      let hyenaToFight one-of hyenas-on rightPatch
      set energy energy - ( [ energy ] of hyenaToFight * loseEnergyOnFight )
      ask hyenaToFight [ die ]
      ask rightPatch
      [
        set pcolor brown
      ]
      report true
    ]
    [
      ifelse leftHyenas = 0 and rightHyenas = 0 and frontHyenas = 1
      [
        let hyenaToFight one-of hyenas-on frontPatch
        set energy energy - ( [ energy ] of hyenaToFight * loseEnergyOnFight )
        ask hyenaToFight [ die ]
        ask frontPatch
        [
          set pcolor brown
        ]
        report true
      ]
      [
        report false
      ]
    ]
  ]
end

to-report challenge-lions
  let leftPatch patch-at 90 1
  let leftLions count lions-on leftPatch
  let rightPatch patch-at -90 1
  let rightLions count lions-on rightPatch
  let frontPatch patch-ahead 1
  let frontLions count lions-on frontPatch
  ifelse leftLions + rightLions + frontLions = 1
  [
    ifelse leftLions = 1
    [
      let lionToFight one-of lions-on leftPatch
      ifelse [ onRest ] of lionToFight = 0
      [
        set energy energy - ( [ energy ] of lionToFight * ( loseEnergyOnFight / groupingLevel ) )
        ask lionToFight [ die ]
        ask leftPatch
        [
          set pcolor red
        ]
        report true
      ]
      [
        report false
      ]
    ]
    [
      ifelse rightLions = 1
      [
        let lionToFight one-of lions-on rightPatch
        ifelse [ onRest ] of lionToFight = 0
        [
          set energy energy - ( [ energy ] of lionToFight * ( loseEnergyOnFight / groupingLevel ) )
          ask lionToFight [ die ]
          ask rightPatch
          [
            set pcolor red
          ]
          report true
        ]
        [
          report false
        ]
      ]
      [
        let lionToFight one-of lions-on frontPatch
        ifelse [ onRest ] of lionToFight = 0
        [
          set energy energy - ( [ energy ] of lionToFight * ( loseEnergyOnFight / groupingLevel ) )
          ask lionToFight [ die ]
          ask frontPatch
          [
            set pcolor red
          ]
          report true
        ]
        [
          report false
        ]
      ]
    ]
  ]
  [
    report false
  ]
end

to respawn-food
  let totalPatches count patches
  let targetLittleFoodCount (littleFood / 100 * totalPatches)
  let currentLittleFoodCount count patches with [ pcolor = brown ]
  let lowerLimit targetLittleFoodCount - ( targetLittleFoodCount * 0.2 )
  let upperLimit targetLittleFoodCount + ( targetLittleFoodCount * 0.2 )
  if currentLittleFoodCount < lowerLimit
  [
    let regenerateLittleFood patches with [ pcolor = black ]
    ask n-of ( lowerLimit - currentLittleFoodCount ) regenerateLittleFood
    [
      set pcolor brown
    ]
  ]
  if currentLittleFoodCount > upperLimit
  [
    let excessLittleFood patches with [ pcolor = brown ]
    ask n-of ( currentLittleFoodCount - upperLimit ) excessLittleFood
    [
      set pcolor black
    ]
  ]
end
to cacador-acao
  movecacadores  ;cacadores movem
  cacaagentes    ;mata agentes
;  prececiona-abrigos ;prececiona abrigos
 cacadoresTrap      ;prececiona traps
  ;cacadores-perceciona-drops ;prececiona drops
end


to movecacadores
  ask cacadores
  [
    ifelse ([pcolor] of patch-here = blue)
    [
      if (any? cacadores-on patch-here)
      [
        if ticks - recarga > 10
        [
          set recarga 0
          set balas balas + 20
          set energy energy + 50
          move-to patch-ahead 3
        ]
      ]
    ]
    [
      ifelse [pcolor] of patch-ahead 1 = blue
      [
        move-to patch-ahead 1
        set recarga ticks
      ]
      [
        ifelse [pcolor] of patch-left-and-ahead 90 1 = blue
        [
          move-to patch-left-and-ahead 90 1
          set recarga ticks
        ]
        [
          ifelse [pcolor] of patch-right-and-ahead 90 1 = blue
          [
            move-to patch-right-and-ahead 90 1
            set recarga ticks
          ]
          [
            ifelse [pcolor] of patch-ahead 1 = brown
            [
              move-to patch-ahead 1
              set nalimentobrown nalimentobrown + 1
              if nalimentobrown = 8
              [
                set balas balas + 10
                set nalimentobrown 0
              ]
              set energy energy + 10
              set pcolor black
            ]
            [
              ifelse [pcolor] of patch-right-and-ahead 90 1 = brown
              [
                move-to patch-right-and-ahead 90 1
                set nalimentobrown  nalimentobrown + 1
                if nalimentobrown = 8
                [
                  set balas balas + 10
                  set nalimentobrown 0
                ]
                set energy energy + 10
                set pcolor black
              ]
              [
                ifelse [pcolor] of patch-left-and-ahead 90 1 = brown
                [
                  move-to patch-left-and-ahead 90 1
                  set energy energy + 10
                  set nalimentobrown nalimentobrown + 1
                  if nalimentobrown = 10
                  [
                    set balas balas + 8
                    set nalimentobrown 0
                  ]
                  set energy energy + 10
                  set pcolor black
                ]
                [
                  ifelse [pcolor] of patch-ahead 1 = red
                  [
                    move-to patch-ahead 1
                    set energy energy + 5
                    set nalimentored nalimentored + 1
                    if nalimentored = 8
                    [
                      set balas balas + 5
                      set nalimentored 0
                    ]
                    set pcolor brown
                  ]
                  [
                    ifelse [pcolor] of patch-right-and-ahead 90 1 = red
                    [
                      move-to patch-right-and-ahead 90 1
                      set energy energy + 5
                      set nalimentored nalimentored + 1
                      if nalimentored = 8
                      [
                        set balas balas + 5
                        set nalimentored 0
                      ]
                      set pcolor brown
                    ]
                    [
                      ifelse [pcolor] of patch-left-and-ahead 90 1 = red
                      [
                        move-to patch-left-and-ahead 90 1
                        set energy energy + 5
                        set nalimentored nalimentored + 1
                        if nalimentored = 10
                        [
                          set balas balas + 5
                          set nalimentored 0
                        ]
                        set pcolor brown
                      ]
                      [
                        set energy energy - 1

                        ifelse [pcolor] of patch-ahead 1 = orange
                        [
                          if [pcolor] of patch-left-and-ahead 90 1 != orange
                          [
                            left 90
                          ]
                          if [pcolor] of patch-right-and-ahead 90 1 != orange
                          [
                            right 90
                          ]
                        ]
                        [
                          ifelse [pcolor] of patch-left-and-ahead 90 1 = orange
                          [
                            if [pcolor] of patch-right-and-ahead 90 1 != orange
                            [
                              right 90
                            ]
                            if [pcolor] of patch-ahead 1 != orange
                            [
                              move-to patch-ahead 1
                            ]
                          ]
                          [
                            ifelse [pcolor] of patch-right-and-ahead 90 1 = orange
                            [
                              if [pcolor] of patch-left-and-ahead 90 1 != orange
                              [
                                left 90
                              ]
                              if [pcolor] of patch-ahead 1 != orange
                              [
                                move-to patch-ahead 1
                              ]
                            ]
                            [
                              ifelse random 101 <= 70 [forward 1]
                              [                                                                   ; se não roda para a direita ou para a esquerda ou avanca 1
                                ifelse random 101 <= 15 [right 90] [left 90]
                              ]
                            ]
                          ]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end
to cacaagentes
  ask cacadores
  [
    if balas > 0
    [
      if any? lions-on patch-ahead 1
      [
        let x one-of lions-on patch-ahead 1
        ifelse [energy] of x <= 100
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)] ;se energia maior que 50 retiralhe metade
          set balas balas - 1
        ]

      ]
      if any? lions-on patch-right-and-ahead 90 1
      [
        let x one-of lions-on patch-right-and-ahead 90 1
        ifelse [energy] of x <= 100
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)] ;se energia maior que 50 retiralhe metade
          set balas balas - 1
        ]
      ]
      if any? lions-on patch-left-and-ahead 90 1
      [
        let x one-of lions-on patch-left-and-ahead 90 1
        ifelse [energy] of x <= 100
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)] ;se energia maior que 50 retiralhe metade
          set balas balas - 1
        ]
      ]
      if any? lions-on patch-ahead 2
      [
        let x one-of lions-on patch-ahead 2
        ifelse [energy] of x <= 100
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)] ;se energia maior que 50 retiralhe metade
          set balas balas - 1
        ]
      ]
      if any? lions-on patch-right-and-ahead 90 2
      [
        let x one-of lions-on patch-right-and-ahead 90 2
        ifelse [energy] of x <= 100
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)] ;se energia maior que 50 retiralhe metade
          set balas balas - 1
        ]
      ]
      if any? lions-on patch-left-and-ahead 90 2
      [
        let x one-of lions-on patch-left-and-ahead 90 2
        ifelse [energy] of x <= 100
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)] ;se energia maior que 50 retiralhe metade
          set balas balas - 1
        ]
      ]
      if any? hyenas-on patch-ahead 1
      [
        let x one-of hyenas-on patch-ahead 1
        ifelse [energy] of x <= 400
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)] ;se energia maior que 50 retiralhe metade
          set balas balas - 1
        ]
      ]
      if any? hyenas-on patch-right-and-ahead 90 1
      [
        let x one-of hyenas-on patch-right-and-ahead 90 1
        ifelse [energy] of x <= 400
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)] ;se energia maior que 50 retiralhe metade
          set balas balas - 1
        ]
      ]
      if any? hyenas-on patch-left-and-ahead 90 1
      [
        let x one-of hyenas-on patch-left-and-ahead 90 1
        ifelse [energy] of x <= 400
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)]
          set balas balas - 1
        ]
      ]
      if any? hyenas-on patch-ahead 2
      [
        let x one-of hyenas-on patch-ahead 2
        ifelse [energy] of x <= 400
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)]
          set balas balas - 1
        ]
      ]
      if any? hyenas-on patch-right-and-ahead 90 2
      [
        let x one-of hyenas-on patch-right-and-ahead 90 2
        ifelse [energy] of x <= 400
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)] ;se energia maior que 50 retiralhe metade
          set balas balas - 1
        ]
      ]
      if any? hyenas-on patch-left-and-ahead 90 2
      [
        let x one-of hyenas-on patch-left-and-ahead 90 2
        ifelse [energy] of x <= 400
        [
          ask x [die]
          set balas balas - 1
        ]
        [
          ask x [set energy energy - (energy * 0.5)] ;se energia maior que 50 retiralhe metade
          set balas balas - 1
        ]
      ]
    ]
  ]
end

to cacadoresTrap ;prececiona traps
  ask cacadores
  [
    if ([pcolor] of patch-right-and-ahead 90 1 = orange) or ([pcolor] of patch-ahead 1 = orange) or ([pcolor] of patch-left-and-ahead 90 1 = orange)
    [
      ifelse energy < 50
      [
        die
      ]
      [
        ifelse energy > 200
        [
          set energy energy - (energy * 0.2)
        ]
        [
          set energy energy - (energy * 0.6)
        ]
      ]
    ]
    if ([pcolor] of patch-right-and-ahead 90 2 = orange) or ([pcolor] of patch-ahead 2 = orange) or ([pcolor] of patch-left-and-ahead 90 2 = orange)
    [
      set energy energy - (energy * 0.1)
    ]
    if [pcolor] of patch-here = orange [die]
  ]
end

to check-death
  ask turtles [ if energy <= 0 [ die ] ]
end

to lions-perceciona-drops
  ask lions[
    if [pcolor] of patch-ahead 1 = magenta
    [
      move-to patch-ahead 1
      set energy energy + energydroplions
      set pcolor black
;      ask one-of patches with [not any? turtles-here and pcolor = black]
 ;     [set pcolor green]
    ]
    if [pcolor] of patch-right-and-ahead 90 1 = magenta
    [
      move-to patch-right-and-ahead 90 1
      set energy energy + energydroplions
      set pcolor black
    ]
    if [pcolor] of patch-left-and-ahead 90 1 = magenta
    [
      move-to patch-left-and-ahead 90 1
      set energy energy + energydroplions
      set pcolor black
    ]
  ]
end

to hyenas-perceciona-drops
  ask hyenas[
    if [pcolor] of patch-ahead 1 = magenta
    [
      move-to patch-ahead 1
      set energy energy + energydrophyenas
      set pcolor black
    ]
    if [pcolor] of patch-right-and-ahead 90 1 = magenta
    [
      move-to patch-right-and-ahead 90 1
      set energy energy + energydrophyenas
      set pcolor black
    ]
    if [pcolor] of patch-left-and-ahead 90 1 = magenta
    [
      move-to patch-left-and-ahead 90 1
      set energy energy + energydrophyenas
      set pcolor black
    ]
  ]
end

to reproduzir-hyenas
  ask hyenas
  [
    if (any? hyenas-on patch-here ) and (count turtles-on patch-here = 2)[
      if random 101 <= taxareproducao_hienas[                                        ; slider para a taxa de reproduçao na interface
        hatch 1[
          set energy initialEnergy
        ]
      ]
    ]
  ]
end
to reproduzir-lions
  ask hyenas
  [
    if (any? lions-on patch-here ) and (count turtles-on patch-here = 2)[
      if random 101 <= taxareproducao_lions[                                        ; slider para a taxa de reproduçao na interface
        hatch 1[
          set energy initialEnergy
        ]
      ]
    ]
  ]
end

;ver energia
to display-labels
  ask turtles [ set label "" ]
  if show-energy [
    ask lions [ set label round energy ]
    ask hyenas [ set label round energy ]
    ask cacadores [set label round energy]
  ]
  if show-balas
  [
    ask cacadores [set label round balas]
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
10
10
513
514
-1
-1
15.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

SLIDER
519
48
664
81
littleFood
littleFood
0
20
20.0
1
1
%
HORIZONTAL

BUTTON
520
12
664
45
SETUP
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
667
12
811
45
GO
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
667
48
812
81
bigFood
bigFood
0
10
5.0
1
1
%
HORIZONTAL

SLIDER
667
83
812
116
energyBigFood
energyBigFood
10
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
519
83
665
116
energyLittleFood
energyLittleFood
1
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
823
46
968
79
blueCells
blueCells
0
5
5.0
1
1
NIL
HORIZONTAL

SLIDER
519
118
665
151
lionsQty
lionsQty
0
100
70.0
1
1
NIL
HORIZONTAL

SLIDER
667
118
812
151
hyenasQty
hyenasQty
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
823
116
968
149
initialEnergy
initialEnergy
0
100
75.0
1
1
NIL
HORIZONTAL

SLIDER
519
153
665
186
minEnergyLevel
minEnergyLevel
1
75
75.0
1
1
NIL
HORIZONTAL

SLIDER
667
153
812
186
loseEnergyOnFight
loseEnergyOnFight
0
0.5
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
823
151
968
184
rest
rest
0
50
50.0
1
1
NIL
HORIZONTAL

SLIDER
531
219
705
252
ncacadores
ncacadores
0
20
3.0
1
1
NIL
HORIZONTAL

SWITCH
1076
230
1189
263
show-balas
show-balas
0
1
-1000

SWITCH
1075
267
1196
300
show-energy
show-energy
0
1
-1000

MONITOR
934
230
1050
275
Número de Hienas
count hyenas
17
1
11

MONITOR
933
274
1041
319
Número de Lions
count lions
17
1
11

MONITOR
935
319
1048
364
Número de Caçadores
count cacadores
17
1
11

SLIDER
530
254
705
287
ntraps
ntraps
0
15
0.0
1
1
NIL
HORIZONTAL

SLIDER
530
287
704
320
dropbonus
dropbonus
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
530
321
704
354
energydroplions
energydroplions
50
200
100.0
50
1
NIL
HORIZONTAL

SLIDER
528
354
706
387
energydrophyenas
energydrophyenas
0
200
200.0
50
1
NIL
HORIZONTAL

PLOT
715
220
915
370
nº agentes
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -9276814 true "" "plot count hyenas"
"pen-1" 1.0 0 -1184463 true "" "plot count lions"
"pen-2" 1.0 0 -5298144 true "" "plot count cacadores"

SLIDER
523
390
708
423
taxareproducao_hienas
taxareproducao_hienas
0
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
526
430
711
463
taxareproducao_lions
taxareproducao_lions
0
20
4.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count lions</metric>
    <metric>count hyenas</metric>
    <enumeratedValueSet variable="littleFood">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loseEnergyOnFight">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="taxareproducao_hienas">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ntraps">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minEnergyLevel">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ncacadores">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energyLittleFood">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rest">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyenasQty">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energyBigFood">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lionsQty">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energydrophyenas">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energydroplions">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blueCells">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="taxareproducao_lions">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dropbonus">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initialEnergy">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-balas">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bigFood">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment2" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count lions</metric>
    <metric>count hyenas</metric>
    <enumeratedValueSet variable="littleFood">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loseEnergyOnFight">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="taxareproducao_hienas">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ntraps">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minEnergyLevel">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ncacadores">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energyLittleFood">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rest">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyenasQty">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energyBigFood">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lionsQty">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energydrophyenas">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energydroplions">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blueCells">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="taxareproducao_lions">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dropbonus">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initialEnergy">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-balas">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bigFood">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment3" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count lions</metric>
    <metric>count hyenas</metric>
    <enumeratedValueSet variable="littleFood">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loseEnergyOnFight">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="taxareproducao_hienas">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ntraps">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minEnergyLevel">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ncacadores">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energyLittleFood">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rest">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyenasQty">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energyBigFood">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lionsQty">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energydrophyenas">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energydroplions">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="blueCells">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="taxareproducao_lions">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dropbonus">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initialEnergy">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-balas">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bigFood">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
