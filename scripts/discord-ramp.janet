# Regenerates Discord's greyscale ramp against a base16 background colour.
#
# Discord derives every greyscale semantic token from `--neutral-1..100`, a
# single monotone white-to-black ramp defined once on `:root`. Polarity is not
# a second ramp -- it is which step a token reaches for, so `.theme-dark` picks
# `--neutral-69` where `.theme-light` picks `--neutral-2`. Replacing the ramp
# therefore recolours both variants at once, and because the remap is monotone
# it preserves every foreground/background pairing Discord chose, which
# per-token overrides are exactly what break.
#
# The remap pivots on the step Discord uses as that polarity's background,
# pinning it to base00 and stretching each side of it into the room that
# leaves. Squeezing the whole 0-100% range into base00..base07 instead would
# wash the backgrounds out -- melange dark would put the chat background at 31%
# lightness against base00's 15%. Vencord's ClientTheme plugin avoids that by
# translating the curve wholesale, but a translation runs off the end: shifting
# melange dark down by 6.274 points flattens steps 93-100 onto pure black. The
# pivot keeps the anchor exact like a translation does, and stays strictly
# descending like the source ramp -- but only for a base00 strictly between
# black and white. A pure black base00 would flatten every step below the
# anchor onto 0, so `ramp-css` rejects the degenerate ends rather than emitting
# a plateau that looks like a working ramp.
#
# Hue and saturation come from base00, so the scheme's tint carries through the
# whole ramp instead of Discord's blue-grey.

# Lightness of each step, in order, read out of Discord's shipped CSS on
# 2026-09-20. Steps absent here keep Discord's own value, so a ramp that grows
# degrades to today's behaviour rather than breaking.
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

# The step Discord uses for the chat background under each polarity, and so the
# step that must land on base00. ClientTheme anchors on the same two.
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

# Every declaration carries !important: Discord ships ~250 of its CSS chunks
# lazily, so a chunk redefining :root can load after quickCss and would
# otherwise win on source order.
(defn declaration [step hue sat lightness]
  (string "  --neutral-" step "-hsl: " (num hue)
          " calc(var(--saturation-factor, 1) * " (num sat) "%) "
          (num lightness) "% !important;"))

(defn ramp-css [hex polarity]
  (def [hue sat lightness] (rgb->hsl (hex->rgb hex)))
  (def anchor (assert (get anchor-step polarity)
                      (string "unknown polarity " polarity)))
  (def from (get ramp (dec anchor)))
  # Scaling collapses one side of the pivot flat when base00 is pure black or
  # pure white. No scheme this repo selects is anywhere near either end, so
  # this is a tripwire, not a case to handle.
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

  # The ramp Discord ships descends without a plateau; a remap of it must too,
  # since every preserved contrast pairing rests on that ordering.
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

  # The pivot exists so neither tail flattens. A translation would put steps
  # 93-100 all on pure black under melange dark; every emitted step must stay
  # distinct and descending, or the contrast pairings the remap is meant to
  # preserve collapse at whichever end the shift overran.
  #
  # `pivot` maps 0 to 0 and 100 to 100 whatever the anchor, so asserting the
  # endpoints would prove nothing about the remap. The precondition the descent
  # actually rests on is the one worth pinning: degenerate ends are rejected,
  # and every base00 this repo can select clears the bar comfortably.
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
