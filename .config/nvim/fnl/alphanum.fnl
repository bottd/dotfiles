; Comparator for table.sort -> (table.sort files an_compare)
; Sorts a list of alphanumeric keys
; example (an_srt [:1 :2 :1a :2a :1a1 :2b2 :2a1])
; result [:1 :1a :1a1 :2 :2a :2a1 :2b2]
(fn path-to-filename [path]
  (path:match "^.+/(.+)$"))

(fn path-to-key [path]
  (var filename (path-to-filename path))
  (var key (filename:match "^(.-)%-"))
  ;; if there is no match, pull id from before "." instead of "-"
  (when (= key nil) (set key (filename:match "^(.-)%.")))
  key)

(fn key-to-list [path]
  (var key (path-to-filename path))
  (var result [(string.sub key 0 0)])
  (var curr_type :num)
  (for [i 1 (length key)]
    (var len (length result))
    (var k (string.sub key i i))
    (var k_type "")
    (if (= (tonumber k) nil)
        (set k_type :alpha)
        (set k_type :num))
    (when (= k_type curr_type)
      (let [item (. result len)]
        (tset result len (.. item k))))
    (when (not (= k_type curr_type))
      (table.insert result k)
      (set curr_type k_type))) ; parse numbers for later comparisons
  (set result (icollect [k v (pairs result)]
                (let [to_num (tonumber v)]
                  (if (= to_num nil)
                      v
                      to_num))))
  result)

(fn an-compare [a b]
  (case [a b]
    (where [x y] (string.find x :index.norg)) (lua "return false")
    (where [x y] (string.find y :index.norg)) (lua "return true"))
  (var a-id (path-to-filename a))
  (var b-id (path-to-filename b))
  (var a-keys (key-to-list a))
  (var b-keys (key-to-list b))
  (var result nil)
  (each [k a-val (pairs a-keys) &until (not (= result nil))]
    (var b-val (. b-keys k))
    (case [a-val b-val]
      [x x] (set result nil)
      [x nil] (set result false)
      [nil y] (set result true)
      (where [x y] (> x y)) (set result false)
      (where [x y] (< x y)) (set result true)))
  (if (= result nil) (set result false))
  result)

{: an-compare}
