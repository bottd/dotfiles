;; mpv-cut config: custom NORG action for clip workflow
;; Videos in ~/media/youtube/ get notes in ~/chalet/references/youtube/
;; Other videos get sibling notes.norg

(local mp _G.mp)
(local utils _G.utils)

(local home (os.getenv :HOME))
(local media-prefix (.. home :/media/youtube/))
(local chalet-prefix (.. home :/chalet/references/youtube/))

(fn format-norg-time [seconds]
  (let [seconds (tonumber seconds)
        h (math.floor (/ seconds 3600))
        m (math.floor (/ (% seconds 3600) 60))
        s (math.floor (% seconds 60))]
    (string.format "%02d:%02d:%02d" h m s)))

(fn scaffold-norg [video-filename]
  (let [ts (os.date "%Y-%m-%dT%H:%M:%S%z")
        ts (.. (ts:sub 1 -3) ":" (ts:sub -2))]
    (.. "@document.meta\n" "title: " video-filename "\n" "created: " ts "\n"
        "updated: " ts "\n" "@end\n" "\n" "* " video-filename "\n" "\n" "** Clips
")))

(fn mkdirp [path]
  (os.execute (.. "mkdir -p '" path "'")))

(fn norg-path-for [video-dir video-filename]
  ;; if video is under ~/media/youtube/, mirror to ~/chalet/references/youtube/
  (if (= 1 (video-dir:find media-prefix 1 true))
      (let [rel (video-dir:sub (+ 1 (length media-prefix)))
            dir (.. chalet-prefix rel)]
        (mkdirp dir)
        (.. dir :notes.norg))
      (utils.join_path video-dir :notes.norg)))

(fn ensure-norg [norg-path video-filename]
  (let [f (io.open norg-path :r)]
    (if f
        (let [content (f:read :*a)]
          (f:close)
          (when (not (content:find "%*%* Clips"))
            (let [content (.. content "\n** Clips\n")
                  f (io.open norg-path :w)]
              (f:write content)
              (f:close)))
          true)
        (let [f (io.open norg-path :w)]
          (when (not f) (lua "return false"))
          (f:write (scaffold-norg video-filename))
          (f:close)
          true))))

(fn append-to-norg [norg-path line]
  (let [f (io.open norg-path :r)]
    (when (not f) (lua "return false"))
    (let [content (f:read :*a)
          _ (f:close)
          content (if (not= (content:sub -1) "\n")
                      (.. content "\n")
                      content)
          f (io.open norg-path :w)]
      (when (not f) (lua "return false"))
      (f:write (.. content line "\n"))
      (f:close)
      true)))

(tset _G.ACTIONS :NORG
      (fn [d]
        (let [norg-path (norg-path-for d.indir d.infile_noext)]
          (if (not (ensure-norg norg-path d.infile_noext))
              (mp.osd_message (.. "Error: cannot write " norg-path) 3)
              (let [start-str (format-norg-time d.start_time)
                    end-str (format-norg-time d.end_time)
                    line (.. "*** " start-str " - " end-str)]
                (if (append-to-norg norg-path line)
                    (mp.osd_message (.. "Clip: " start-str " - " end-str) 3)
                    (mp.osd_message "Error writing clip" 3)))))))

(fn norg-bookmark []
  (let [pos (mp.get_property_number :time-pos)]
    (when pos
      (let [inpath (mp.get_property :path)]
        (when inpath
          (let [indir (utils.split_path inpath)
                infile-noext (mp.get_property :filename/no-ext)
                norg-path (norg-path-for indir infile-noext)]
            (if (not (ensure-norg norg-path infile-noext))
                (mp.osd_message (.. "Error: cannot write " norg-path) 3)
                (let [time-str (format-norg-time pos)
                      line (.. "*** " time-str)]
                  (if (append-to-norg norg-path line)
                      (mp.osd_message (.. "Bookmark: " time-str) 3)
                      (mp.osd_message "Error writing bookmark" 3))))))))))

(set _G.ACTION :NORG)
(set _G.KEY_CUT :c)
(set _G.KEY_CANCEL_CUT :C)
(set _G.KEY_BOOKMARK_ADD :i)
(set _G.KEY_CYCLE_ACTION :a)

(mp.add_key_binding :b :norg-bookmark norg-bookmark)
