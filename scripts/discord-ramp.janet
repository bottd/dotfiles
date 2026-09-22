# Tint Discord's neutral ramp with base00 and anchor the chat background to it.
# Scale lightness on either side of the anchor to preserve ordering without clipping.

# Lightness values from Discord's CSS, 2026-09-20.
(def ramp
  [100 98.431 97.059 95.49 94.118 92.549 91.373 89.804 88.431 86.863 85.49
   83.922 82.745 81.176 79.804 78.235 77.059 75.49 74.118 72.549 71.373 70
   68.431 67.255 65.686 64.314 63.137 61.569 60.392 59.02 57.647 56.275 55.098
   53.529 52.353 50.98 49.608 48.235 47.059 45.882 44.314 43.137 41.961 40.588
   39.412 38.235 36.863 35.49 34.314 33.137 32.353 31.765 31.176 30.588 29.804
   29.216 28.431 28.039 27.255 26.471 25.882 25.294 24.706 23.922 23.529
   22.745 22.157 21.569 20.98 20.392 19.608 19.216 18.431 18.039 17.255 16.667
   16.275 15.49 15.098 14.314 13.725 13.333 12.549 12.157 11.373 10.98 10.392
   9.804 9.216 8.824 8.039 7.451 6.863 5.882 5.098 4.314 3.137 2.157 0.98 0])

# Chat background step for each polarity.
(def anchor-step {:dark 69 :light 2})

(defn hex->rgb [hex]
  (def digits (string/replace "#" "" hex))
  (assert (= 6 (length digits)) (string "expected 6 hex digits, got " hex))
  (map (fn [i] (/ (scan-number (string "0x" (string/slice digits i (+ i 2)))) 255))
       [0 2 4]))

(defn rgb->hsl [[r g b]]
  (def mx (max r g b))
  (def mn (min r g b))
  (def l (/ (+ mx mn) 2))
  (def d (- mx mn))
  (if (zero? d)
    [0 0 (* 100 l)]
    [(cond
       (= mx r) (* 60 (mod (/ (- g b) d) 6))
       (= mx g) (* 60 (+ 2 (/ (- b r) d)))
       (* 60 (+ 4 (/ (- r g) d))))
     (* 100 (/ d (- 1 (math/abs (- (* 2 l) 1)))))
     (* 100 l)]))

# Map a source lightness onto the target ramp, holding `from` at `to` and
# scaling each side of the pivot independently so neither end overruns 0/100.
(defn pivot [from to source]
  (if (<= source from)
    (* source (/ to from))
    (+ to (* (- source from) (/ (- 100 to) (- 100 from))))))

(defn num [x] (string/format "%.3f" x))

# !important prevents lazy-loaded Discord CSS from overriding the ramp.
(defn declaration [step hue sat lightness]
  (string "  --neutral-" step "-hsl: " (num hue)
          " calc(var(--saturation-factor, 1) * " (num sat) "%) "
          (num lightness) "% !important;"))

(defn ramp-css [hex polarity]
  (def [hue sat lightness] (rgb->hsl (hex->rgb hex)))
  (def anchor (assert (get anchor-step polarity)
                      (string "unknown polarity " polarity)))
  (def from (get ramp (dec anchor)))
  # Pure black or white would flatten one side of the pivot.
  (assert (< 0 lightness 100)
          (string "base00 must not be pure black or white, got L=" lightness))
  (string ":root {\n"
          (string/join
            (seq [i :range [0 (length ramp)]]
              (declaration (inc i) hue sat (pivot from lightness (get ramp i))))
            "\n")
          "\n}\n"))

(defn lightness-of [css step]
  (scan-number
    (first (peg/match ~(some (+ (* "--neutral-" ,(string step) "-hsl: "
                                   (some (if-not "%" 1)) "%) "
                                   (<- (some (if-not "%" 1))))
                                1))
                      css))))

(defn selftest []
  (assert (deep= [1 1 1] (freeze (hex->rgb "FFFFFF"))))
  (assert (deep= [0 0 0] (freeze (hex->rgb "#000000"))))
  (assert (deep= [0 0 100] (freeze (rgb->hsl [1 1 1]))))
  (assert (deep= [0 0 0] (freeze (rgb->hsl [0 0 0]))))
  (assert (deep= [0 100 50] (freeze (rgb->hsl [1 0 0]))))
  (assert (= 120 (first (rgb->hsl [0 1 0]))))
  (assert (= 240 (first (rgb->hsl [0 0 1]))))
  (assert (= 100 (length ramp)))

  # Both source and emitted ramps must be strictly descending.
  (each [a b] (partition 2 (interleave ramp (drop 1 ramp)))
    (assert (> a b) (string "ramp not descending at " a)))

  # melange dark: base00 #292522 is a warm near-black.
  (def dark (ramp-css "292522" :dark))
  (def [hue sat lightness] (rgb->hsl (hex->rgb "292522")))
  (assert (< 20 hue 30) (string "expected a warm hue, got " hue))
  (assert (= (num lightness) (num (lightness-of dark 69)))
          "step 69 must land exactly on base00 under :dark")
  (assert (string/find "!important" dark))

  # melange light: base00 #F1F1F1, anchored at step 2 instead.
  (def light (ramp-css "F1F1F1" :light))
  (assert (= (num (last (rgb->hsl (hex->rgb "F1F1F1"))))
             (num (lightness-of light 2)))
          "step 2 must land exactly on base00 under :light")

  # Reject degenerate endpoints and check descent after CSS rounding.
  (each [hex polarity] [["000000" :dark] ["FFFFFF" :light]]
    (assert (not (first (protect (ramp-css hex polarity))))
            (string hex " " polarity " should have been rejected")))
  (defn emitted [css] (map (fn [n] (lightness-of css n)) (range 1 101)))
  (each hex ["292522" "F1F1F1" "010409" "fafbfc"]
    (each polarity [:dark :light]
      (def steps (emitted (ramp-css hex polarity)))
      (each [a b] (partition 2 (interleave steps (drop 1 steps)))
        (assert (> a b)
                (string hex " " polarity " not descending at " a)))))
  (print "ok"))

(defn main [_ & args]
  (case (first args)
    "selftest" (selftest)
    (if (= 2 (length args))
      (prin (ramp-css (first args) (keyword (get args 1))))
      (do (eprint "usage: discord-ramp <base00-hex> <dark|light> | selftest")
        (os/exit 1)))))
