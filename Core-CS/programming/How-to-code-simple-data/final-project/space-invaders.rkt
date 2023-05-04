;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders-starter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders


;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
(define TANK-SPEED 2)
(define MISSILE-SPEED 10)

(define HIT-RANGE 10)

(define INVADE-RATE 100)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))

(define MISSILE (ellipse 5 15 "solid" "red"))

(define INVADE-INCREASE 10)
(define MAX-RANDOM-X 30)
(define MAX-RANDOM-DX 2)

;; Data Definitions:

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition

#;
(define (fn-for-game s)
  (... (fn-for-loinvader (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))


(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))


(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick
;; NOTE: to ensure the specification that the invaders move at 45 degrees:
;;       dy = dx

(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right

#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))


;; ListOfInvader is one of:
;;  - empty
;;  - (cons Invader ListOfInvader)
;; interp. a list of invaders
(define LOI0 empty)
(define LOI1 (list I1))
(define LOI2 (list I1 I2))
(define LOI-START (list (make-invader (/ WIDTH 2) 0 2))) ; first invader in game

#;
(define (fn-for-loinvaders loi)
  (cond [(empty? loi) (...)]
        [else (fn-for-invader (first loi))
              (fn-for-loinvaders (rest loi))]))

;; ListOfMissile is one of:
;;  - empty
;;  - (cons Missile ListOfMissile)
;; interp. a list of missiles
(define LOM0 empty)
(define LOM1 (list M1))
(define LOM2 (list M1 M2))

#;
(define (fn-for-lom lom)
  (cond [(empty? lom) (...)]
        [else (fn-for-missile (first lom))
              (fn-for-lom (rest lom))]))


(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))


;; =================
;; Functions:

;; Game -> Game
;; start the world with (main G0)
;; 
(define (main s)
  (big-bang s                 ; Game
    (on-tick   next-game)     ; Game -> Game
    (to-draw   render-game)   ; Game -> Image
    (on-key    handle-key)    ; Game KeyEvent -> Game
    (stop-when game-over?)))  ; Game -> Boolean

;; Game -> Game
;; produce the next game state
(check-expect (next-game G1) (make-game (list (make-invader (/ WIDTH 2) 0 2)) empty (make-tank (+ 50 TANK-SPEED) 1)))
(check-expect (next-game G3) (make-game (next-invaders (list I2)) (next-missiles (list M1)) (next-tank T1)))

;(define (next-game s) s) ;stub

;;<Function composition - no template>

(define (next-game s)
  (advance (filter s)))

;; ###################
;; filter and helpers:

;; Game -> Game
;; filter invaders and missiles
(check-expect (filter G2) G2)
(check-expect (filter G3) (make-game (list I2) (list M1) T1))

;(define (filter s) s) ;stub

;;<Template from Game>

(define (filter s)
  (make-game (filter-invaders (game-invaders s) (missiles->posns (game-missiles s)))
             (filter-missiles (game-missiles s) (invaders->posns (game-invaders s)))
             (game-tank s)))

;; ListOfInvader (listof posn) -> ListOfInvader
;; filter invaders within collision range of a missile
(check-expect (filter-invaders empty empty) empty)
(check-expect (filter-invaders LOI2 (missiles->posns LOM2)) (list I2))

;(define (filter-invaders loi lom) loi) ;stub

;;<Template for ListOfInvader>

(define (filter-invaders loi lom-posns)
  (cond [(empty? loi) empty]
        [else (if (list-collides? (invader->posn (first loi)) lom-posns)
                  (filter-invaders (rest loi) lom-posns)
                  (cons (first loi) (filter-invaders (rest loi) lom-posns)))]))

;; ListOfMissile (listof posn) -> ListOfMissile
;; filter missiles within collision range of an invader or offscreen
(check-expect (filter-missiles empty empty) empty)
(check-expect (filter-missiles LOM2 (invaders->posns LOI2)) (list M1))

;(define (filter-missiles lom loi-posns) lom) ;stub

;;<Template for ListOfInvader>

(define (filter-missiles lom loi-posns)
  (cond [(empty? lom) empty]
        [else (if (or (list-collides? (missile->posn (first lom)) loi-posns) (offscreen? (first lom)))
                  (filter-missiles (rest lom) loi-posns)
                  (cons (first lom) (filter-missiles (rest lom) loi-posns)))]))

;; Missile -> Boolean
;; produce true if missile is offscreen
(check-expect (offscreen? M1) false)
(check-expect (offscreen? (make-missile  5 (- 0 (image-height MISSILE)))) true)
;(define (offscreen? m) false) ;stub
;;<Template from Missile>
(define (offscreen? m)
  (<= (missile-y m) (- 0 (image-height MISSILE))))


;; ListOfInvader -> (listof posn)
;; extract posns of all invaders
(check-expect (invaders->posns empty) empty)
(check-expect (invaders->posns LOI2) (list (make-posn 150 100) (make-posn 150 HEIGHT)))
;(define (invaders->posns loi) empty) ;stub
;;<Template from ListOfInvader>
(define (invaders->posns loi)
  (cond [(empty? loi) empty]
        [else (cons (invader->posn (first loi))
                    (invaders->posns (rest loi)))]))

;; Invader -> Posn
;; extract invader posn
(check-expect (invader->posn I1) (make-posn 150 100))
;(define (invader->posn i) (make-posn 0 0)) ;stub
;;<Template from Invader>
(define (invader->posn i)
  (make-posn (invader-x i) (invader-y i)))

;; ListOfMissile -> (listof posn)
;; extract posns of all missiles
(check-expect (missiles->posns empty) empty)
(check-expect (missiles->posns (list M1 M1)) (list (make-posn 150 300) (make-posn 150 300)))
;(define (missiles->posns lom) empty) ;stub
;;<Template from ListOfMissile>
(define (missiles->posns lom)
  (cond [(empty? lom) empty]
        [else (cons (missile->posn (first lom))
                    (missiles->posns (rest lom)))]))

;; Missile -> Posn
;; extract missile's posn
(check-expect (missile->posn M1) (make-posn 150 300))
;(define (missile->posn m) (make-posn 0 0)) ;stub
;;<Template from Invader>
(define (missile->posn m)
  (make-posn (missile-x m) (missile-y m)))


;; Posn (listof posn) -> Boolean
;; produce true if the given posn is in hit range of given posns
(check-expect (list-collides? (make-posn 50 50) empty) false)
(check-expect (list-collides? (invader->posn I1) (missiles->posns LOM2)) true) ;invader->missiles
(check-expect (list-collides? (invader->posn I1) (missiles->posns (list M1 M3))) true)
(check-expect (list-collides? (invader->posn I1) (missiles->posns (list M1 M1))) false)
(check-expect (list-collides? (missile->posn M1) (invaders->posns LOI2)) false) ;missile->invaders
(check-expect (list-collides? (missile->posn M2) (invaders->posns LOI2)) true)

;(define (list-collides? p lop) false) ;stub

#;
(define (fn-for-lop lop)
  (cond [(empty? lop) (...)]
        [else (fn-for-posn (first lop))
              (fn-for-lop (rest lop))]))

(define (list-collides? p lop)
  (cond [(empty? lop) false]
        [else (or (collides? p (first lop))
                  (list-collides? p (rest lop)))]))

;; Posn Posn -> Boolean
;; produce true if the 2 posns are within collision range
(check-expect (collides? (invader->posn I1) (missile->posn M1)) false)
(check-expect (collides? (invader->posn I1) (missile->posn M2)) true)
(check-expect (collides? (invader->posn I1) (missile->posn M3)) true)
(check-expect (collides? (invader->posn I2) (missile->posn M2)) false)

;(define (collides? p1 p2) false) ;stub

#;
(define (collides? p1 p2)
  (... (posn-x p1) (posn-y p1) (posn-x p2) (posn-y p2)))

(define (collides? p1 p2)
  (<= (distance (posn-x p1) (posn-x p2) (posn-y p1) (posn-y p2)) HIT-RANGE))

;; Number Number Number Number -> Number
;; compute distance between 2 points
(check-expect (distance 5 1 3 6) 5)
;(define (distance x1 x2 y1 y2) 0) ;stub

#;
(define (distance x1 x2 y1 y2)
  (... x1 x2 y1 y2))

(define (distance x1 x2 y1 y2)
  (sqrt (+ (sqr (- x1 x2)) (sqr (- y1 y2)))))


;; ###################
;; advance and helpers:

;; Game -> Game
;; Advance all components and spawn random invader
(check-expect (advance G1) (make-game LOI-START empty (make-tank (+ 50 TANK-SPEED) 1)))
(check-random (advance G2) (make-game (next-invaders (list I1)) (list (make-missile 150 (- 300 MISSILE-SPEED))) (next-tank T1)))

;;<Template from Game>

(define (advance s)
  (make-game (next-invaders (game-invaders s))
             (next-missiles (game-missiles s))
             (next-tank (game-tank s))))

;; ListOfInvader -> ListOfInvader
;; advance invaders and randomly produce new one
(check-expect (next-invaders empty) LOI-START)
(check-random (next-invaders LOI1) (if (new-invader? 1)
                                       (cons (make-new-invader I1) (move-invaders LOI1))
                                       (move-invaders LOI1)))

;(define (next-invaders loi) loi) ;stub

;;<Template from ListOfInvader>

(define (next-invaders loi)
  (cond [(empty? loi) LOI-START]
        [else (if (new-invader? (length loi))
                  (cons (make-new-invader (first loi)) (move-invaders loi))
                  (move-invaders loi))]))

;; Natrual -> Boolean
;; randomly produce true to determine whether to make a new invader,
;; taking the current number of invaders into account:
;; the more invaders, the less likely that a new invader will spawn
(check-random (new-invader? 0) (= (random INVADE-RATE) 1))
(check-random (new-invader? 10) (= (random (+ INVADE-RATE (* INVADE-INCREASE 10))) 1))
;(define (new-invader? l) false) ;stub
;(define (new-invader? l) (... l)) ;template
(define (new-invader? l)
  (= (random (+ INVADE-RATE (* INVADE-INCREASE l))) 1))

;; Invader -> Invader
;; generate a new invader with random properties, approximate to given invader
(check-random (make-new-invader I1) (make-invader (+ 150 (random-sign (random MAX-RANDOM-X))) 0 (random-sign (+ 12 (random MAX-RANDOM-DX)))))
;(define (make-new-invader invader) I1) ;stub
;;<Template from Invader>
(define (make-new-invader i)
  (make-invader (+ (invader-x i) (random-sign (random MAX-RANDOM-X))) 0 (random-sign (+ (invader-dx i) (random MAX-RANDOM-DX)))))

;; Number -> Number
;; randomly flip the given number's sign
(check-expect (random-sign 0) 0)
(check-random (random-sign 5) (if (= (random 2) 0) 5 (- 5)))
;(define (random-sign n) n)         ;stub
;(define (random-sign n) (... n))   ;template
(define (random-sign n)
  (if (= (random 2) 0) n
      (- n)))

;; ListOfInvader -> ListOfInvader
;; move all invaders
(check-expect (move-invaders empty) empty)
(check-expect (move-invaders LOI1) (list (make-invader (+ 150 12) (+ 100 12) 12)))
(check-expect (move-invaders LOI2) (list (move-invader I1) (move-invader I2)))

;(define (move-invaders loi) loi) ;stub

;;<Template from ListOfInvader>

(define (move-invaders loi)
  (cond [(empty? loi) empty]
        [else (cons (move-invader (first loi))
                    (move-invaders (rest loi)))]))

;; Invader -> Invader
;; move invader 1 step and switch direction on wall collision
(check-expect (move-invader I1) (make-invader (+ 150 12) (+ 100 12) 12))
(check-expect (move-invader (make-invader WIDTH 100 12)) (make-invader (- WIDTH 12) 112 -12)) ;right->left
(check-expect (move-invader (make-invader 0 100 -12)) (make-invader 12 112 12)) ;left->right

;(define (move-invader i) i) ;stub

;;<Template from Invader>

(define (move-invader i)
  (if (< 0 (invader-x i) WIDTH)
      (make-invader (+ (invader-x i) (invader-dx i)) (+ (invader-y i) (abs (invader-dx i))) (invader-dx i))
      (make-invader (- (invader-x i) (invader-dx i)) (+ (invader-y i) (abs (invader-dx i))) (* -1 (invader-dx i)))))

;; ListOfMissile -> ListOfMissile
;; Advance missiles
(check-expect (next-missiles empty) empty)
(check-expect (next-missiles LOM2) (list (make-missile 150 (- 300 MISSILE-SPEED)) (make-missile (invader-x I1) (- (+ (invader-y I1) 10) MISSILE-SPEED))))

;(define (next-missiles lom) lom) ;stub

;;<Template from ListOfMissile>

(define (next-missiles lom)
  (cond [(empty? lom) empty]
        [else (cons (move-missile (first lom))
                    (next-missiles (rest lom)))]))

;; Missile -> Missile
;; move missile up by MISSILE-SPEED
(check-expect (move-missile M1) (make-missile 150 (- 300 MISSILE-SPEED)))
;(define (move-missile m) m) ;stub
;;<Template from Missile>
(define (move-missile m)
  (make-missile (missile-x m) (- (missile-y m) MISSILE-SPEED)))

;; Tank -> Tank
;; move tank in given direction by TANK-SPEED
(check-expect (next-tank T1) (make-tank (+ 50 TANK-SPEED) 1))
(check-expect (next-tank T2) (make-tank (+ 50 (* -1 TANK-SPEED)) -1))

;(define (next-tank t) t) ;stub

;;<Template from Tank>

(define (next-tank t)
  (make-tank (+ (tank-x t) (* (tank-dir t) TANK-SPEED)) (tank-dir t)))


;; ###################
;; render-game and helpers:

;; Game -> Image
;; render the current game state 
(check-expect (render-game G0) (place-image empty-image 0 0
                                            (place-image empty-image 0 0
                                                         (place-image TANK (tank-x T0) (- HEIGHT TANK-HEIGHT/2) BACKGROUND))))
(check-expect (render-game G2) (place-image INVADER (invader-x I1) (invader-y I1)
                                            (place-image MISSILE (missile-x M1) (missile-y M1)
                                                         (place-image TANK (tank-x T1) (- HEIGHT TANK-HEIGHT/2) BACKGROUND))))
(check-expect (render-game G3) (place-image INVADER (invader-x I1) (invader-y I1)
                                            (place-image INVADER (invader-x I2) (invader-y I2)
                                                         (place-image MISSILE (missile-x M1) (missile-y M1)
                                                                      (place-image MISSILE (missile-x M2) (missile-y M2)
                                                                                   (place-image TANK (tank-x T1) (- HEIGHT TANK-HEIGHT/2) BACKGROUND))))))
;(define (render s) BACKGROUND) ;stub

;;<Template from Game>

(define (render-game s)
  (render-invaders (game-invaders s)
                   (render-missiles (game-missiles s)
                                    (render-tank (game-tank s) BACKGROUND))))

;; Tank Image -> Image
;; Render tank on screen at tank's pos
(check-expect (render-tank T1 BACKGROUND) (place-image TANK (tank-x T1) (- HEIGHT TANK-HEIGHT/2) BACKGROUND))

;(define (render-tank t bg) bg) ;stub

;;<Template from Tank>

(define (render-tank t bg)
  (place-image TANK (tank-x t) (- HEIGHT TANK-HEIGHT/2) bg))

;; ListOfMissile Image -> Image
;; Render missiles on given image at their respective positions
(check-expect (render-missiles empty BACKGROUND) BACKGROUND)
(check-expect (render-missiles LOM2 BACKGROUND)
              (place-image MISSILE (missile-x M1) (missile-y M1)
                           (place-image MISSILE (missile-x M2) (missile-y M2) BACKGROUND)))

;(define (render-missiles lom base-img) base-img) ;stub

;;<Template from ListOfMissile>

(define (render-missiles lom base-img)
  (cond [(empty? lom) base-img]
        [else (place-image MISSILE (missile-x (first lom)) (missile-y (first lom))
                           (render-missiles (rest lom) base-img))]))


;; ListOfInvader Image -> Image
;; Render invaders on given image at their respective positions
(check-expect (render-invaders empty BACKGROUND) BACKGROUND)
(check-expect (render-invaders LOI2 BACKGROUND)
              (place-image INVADER (invader-x I1) (invader-y I1)
                           (place-image INVADER (invader-x I2) (invader-y I2) BACKGROUND)))

;(define (render-invaders loi base-img) base-img) ;stub

;;<Template from ListOfInvader>

(define (render-invaders loi base-img)
  (cond [(empty? loi) base-img]
        [else (place-image INVADER (invader-x (first loi)) (invader-y (first loi))
                           (render-invaders (rest loi) base-img))]))


;; ###################
;; handle-key and helpers:

;; Game KeyEvent -> Game
;; on left or right arrow press, move the player accordingly
;; on space, shoot a new missile
(check-expect (handle-key G1 "left") (make-game empty empty T2)) ;right->left
(check-expect (handle-key G1 "right") (make-game empty empty T1)) ;right->right
(check-expect (handle-key (make-game empty empty T2) "left") (make-game empty empty T2)) ;left->left
(check-expect (handle-key (make-game empty empty T2) "right") (make-game empty empty T1)) ;left->left
(check-expect (handle-key (make-game (list I1 I2) (list M1 M2) T1) "left") (make-game (list I1 I2) (list M1 M2) T2))
(check-expect (handle-key G1 "up") G1) ;stays the same
(check-expect (handle-key G1 " ") (make-game empty (list (make-missile 50 (- HEIGHT TANK-HEIGHT/2))) T1)) ;stays the same

;(define (handle-key s ke) s) ;stub

#;
(define (handle-key s ke)
  (cond [(key=? ke "left") (... s)]
        [(key=? ke "right") (... s)]
        [(key=? ke " ") (... s)]
        [else (... s)]))

(define (handle-key s ke)
  (cond [(key=? ke "left") (make-game (game-invaders s) (game-missiles s) (change-dir (game-tank s) -1))]
        [(key=? ke "right") (make-game (game-invaders s) (game-missiles s) (change-dir (game-tank s) 1))]
        [(key=? ke " ") (make-game (game-invaders s) (add-missile (game-missiles s) (game-tank s)) (game-tank s))]
        [else s]))

;; Tank Integer[-1, 1] -> Tank
;; Change tank direction to the given dir
(check-expect (change-dir T1 1) T1)
(check-expect (change-dir T1 -1) T2)
(check-expect (change-dir T2 1) T1)
(check-expect (change-dir T2 -1) T2)

;(define (change-dir t dir) t) ;stub

;;<Template from Tank>

(define (change-dir t dir)
  (make-tank (tank-x t) dir))

;; ListOfMissile Tank -> ListOfMiisle
;; add a new missile at the position of the tank given
(check-expect (add-missile empty T1) (list (make-missile 50 (- HEIGHT TANK-HEIGHT/2))))
(check-expect (add-missile LOM2 T1) (cons (make-missile 50 (- HEIGHT TANK-HEIGHT/2)) LOM2))

;(define (add-missile lom t) lom) ;stub

;;<Template from Tank>

(define (add-missile lom t)
  (cons (make-missile (tank-x t) (- HEIGHT TANK-HEIGHT/2))
        lom))


;; ###################
;; game-over:

;; Game -> Boolean
;; produce true if invader reached the bottom
(check-expect (game-over? G0) false)
(check-expect (game-over? (make-game (list (make-invader 100 (+ HEIGHT 50) 5)) LOM2 T1)) true)

;(define (game-over? s) false) ;stub

;;<Template from Game>

(define (game-over? s)
  (list-reached-bottom? (game-invaders s)))

;; ListOfInvader -> ListOfInvader
;; produce true if any invader has reached bottom
(check-expect (list-reached-bottom? empty) false)
(check-expect (list-reached-bottom? (list I1)) false)
(check-expect (list-reached-bottom? (list I1 I2)) true)

;(define (list-reached-bottom? loi) false) ;stub

;;<Template from ListOfInvader>

(define (list-reached-bottom? loi)
  (cond [(empty? loi) false]
        [else (or (reached-bottom? (first loi))
                  (list-reached-bottom? (rest loi)))]))

;; Invader -> Boolean
;; produce true if invader reached bottom
(check-expect (reached-bottom? I1) false)
(check-expect (reached-bottom? I2) true)
(check-expect (reached-bottom? I3) true)

;(define (reached-bottom? i) false) ;stub

;;<Template from Invader>

(define (reached-bottom? i)
  (>= (invader-y i) HEIGHT))